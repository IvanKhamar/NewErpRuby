module Production
  # Writing off consumables and cut parts for one cutting or sewing operation, by the BOMs. If something is short,
  # what there is gets written off and the shortage goes to warnings: the workshop has already cut or sewn, so the
  # record must not be refused (the old module's behaviour).
  class Consumption
    include BusinessText

    attr_reader :warnings

    # Loads and locks everything the model's BOMs can touch. Called inside the operation's transaction, after the
    # size rows were locked; items are locked in id order, like everywhere else, so there is no deadlock.
    def initialize(model, actor)
      @model = model
      @actor = actor
      @warnings = []
      @components = model.components.includes(:bom_lines).to_a
      @sewn_bom = model.sewn_bom_lines.to_a
      item_ids = (@components.flat_map { |c| c.bom_lines.map(&:item_id) } + @sewn_bom.filter_map(&:item_id)).uniq
      @items = StockItem.lock.where(item_id: item_ids).order(:item_id).index_by(&:id)
      @stocks = ComponentStock.lock.where(component_id: @components.map(&:id)).index_by do |s|
        [s.component_id, s.size_id]
      end
    end

    # "+Покроєно": every part gets +quantity, its consumables are written off by the cutting BOM.
    def for_cut(size, quantity)
      @components.each do |component|
        Bom.resolve(component.bom_lines, size.id, :item_id).each do |line|
          comment = "Крій: #{@model.name}, #{component.name}, #{size.size_name} x#{plain(quantity, 3)}"
          take_item(line.item_id, line.qty_per_unit * quantity, comment)
        end
        stock_of(component.id, size.id).stock += quantity
      end
    end

    # "+Пошито": cut parts come from their stock, direct consumables (threads, labels) from the warehouse.
    def for_sewing(size, quantity)
      Bom.resolve(@sewn_bom, size.id, :component_id).each { |line| take_parts(line, size, quantity) }
      Bom.resolve(@sewn_bom, size.id, :item_id).each do |line|
        take_item(line.item_id, line.qty_per_unit * quantity,
                  "Пошив: #{@model.name}, #{size.size_name} x#{plain(quantity, 3)}")
      end
    end

    def save!
      @items.each_value { |item| item.save! if item.changed? } # saves its new movement rows too
      @stocks.each_value { |stock| stock.save! if stock.new_record? || stock.changed? }
    end

    private

    def take_parts(line, size, quantity)
      need = line.qty_per_unit * quantity
      taken = stock_of(line.component_id, size.id).take_up_to(need)
      return if taken >= need

      name = @components.find { |c| c.id == line.component_id }&.name || "деталь #{line.component_id}"
      @warnings << "Бракує розкроєних деталей «#{name}» розміру #{size.size_name}: #{plain(need - taken, 3)} шт. " \
                   "Взято #{plain(taken, 3)} з #{plain(need, 3)}."
    end

    def take_item(item_id, need, comment)
      item = @items[item_id]
      if item.nil?
        @warnings << "Розхідника #{item_id} зі специфікації немає на складі, його не списано."
        return
      end
      # Long model and part names may not fit into the log comment (255 characters).
      movement = item.take_up_to(need, comment[0, 255], @actor)
      taken = movement&.quantity || 0
      return if taken >= need

      @warnings << "Бракує #{plain(need - taken, 3)} #{item.unit}: #{item.name}. " \
                   "Списано #{plain(taken, 3)} з #{plain(need, 3)}."
    end

    def stock_of(component_id, size_id)
      @stocks[[component_id, size_id]] ||= ComponentStock.new(component_id:, size_id:, stock: 0)
    end
  end
end
