module Production
  # One production operation for several sizes at once: cut, to-sewing, sewn or ship.
  # Cutting and sewing write off consumables and parts by the BOMs (Production::Consumption). Everything is one
  # transaction with the touched rows locked, so a half-written operation never stays in the database.
  class RecordOperation < ApplicationService
    OPERATIONS = %w[cut to-sewing sewn ship].freeze
    SEWN_OPERATIONS = %w[sewn ship].freeze

    SizeChange = Data.define(:size_id, :size_name, :before, :after)
    Outcome = Data.define(:sizes, :warnings)
    Row = Data.define(:size_id, :quantity)

    def initialize(production_id:, operation:, rows:, comment:, warehouse_id:, user:)
      @production_id = production_id
      @operation = operation
      @rows = rows
      @comment = comment
      @warehouse_id = warehouse_id
      @user = user
    end

    def call
      problem = request_problem
      return problem if problem

      ApplicationRecord.transaction do
        model = ProductionModel.active.find_by(production_id: @production_id)
        return not_found("Модель #{@production_id} не знайдено.") if model.nil?

        # Lock the sizes first; the consumption then locks items and part stocks (always in this order).
        sizes = ProductionSize.lock.where(production_id: model.id).order(:size_id).index_by(&:id)
        consumption = Consumption.new(model, @user) if %w[cut sewn].include?(@operation)
        changes = @rows.map { |row| apply(model, sizes, row, consumption) }
        sizes.each_value(&:save!)
        consumption&.save!
        success(Outcome.new(sizes: changes, warnings: consumption&.warnings || []))
      end
    end

    private

    def request_problem
      return failure("Вкажіть кількість хоча б для одного розміру.") if @rows.empty?

      duplicate = @rows.map(&:size_id).tally.find { |_, count| count > 1 }&.first
      return failure("Розмір #{duplicate} указано двічі.") if duplicate
      return if @warehouse_id.nil?
      unless SEWN_OPERATIONS.include?(@operation)
        return failure("Склад вказують лише для пошитого й відвантаженого: крій живе на основному складі.")
      end

      not_found("Склад #{@warehouse_id} не знайдено.") unless Warehouse.exists?(@warehouse_id)
    end

    def apply(model, sizes, row, consumption)
      size = sizes[row.size_id] || model.require_size(row.size_id) # raises the "not of this model" error
      entry = case @operation
              when "cut" then size.record_cut(row.quantity, @comment, @user)
              when "to-sewing" then size.send_to_sewing(row.quantity, @comment, @user)
              when "sewn" then sewn(size, row.quantity)
              when "ship" then ship(size, row.quantity)
              end
      consumption&.for_cut(size, row.quantity) if @operation == "cut"
      consumption&.for_sewing(size, row.quantity) if @operation == "sewn"
      SizeChange.new(size_id: size.id, size_name: size.size_name, before: entry.stock_before, after: entry.stock_after)
    end

    def sewn(size, quantity)
      entry = size.record_sewn(quantity, @comment, @user)
      change_location(size, quantity) if @warehouse_id
      entry
    end

    # Pieces leave a place not through an order. With pieces at other warehouses, the main warehouse has only the
    # rest of the sewn stock, and shipping from it cannot take what lies elsewhere.
    def ship(size, quantity)
      locations = ProductionLocation.lock.where(size_id: size.id).to_a
      available = if @warehouse_id
                    locations.find { |l| l.warehouse_id == @warehouse_id }&.quantity || 0
                  elsif locations.any? { |l| !l.quantity.zero? }
                    size.sewn_stock - locations.sum(&:quantity)
                  end
      if available && quantity.positive? && [available, 0].max < quantity
        place = @warehouse_id ? "на цьому складі" : "на основному складі"
        raise DomainError, "Розмір #{size.size_name}: #{place} пошито #{BusinessText.plain(available, 3)}, " \
                           "потрібно #{BusinessText.plain(quantity, 3)}."
      end
      entry = size.ship(quantity, @comment, @user)
      change_location(size, -quantity) if @warehouse_id
      entry
    end

    def change_location(size, delta)
      location = ProductionLocation.lock.find_or_initialize_by(size_id: size.id, warehouse_id: @warehouse_id)
      location.quantity = location.quantity.to_d + delta
      location.save!
    end
  end
end
