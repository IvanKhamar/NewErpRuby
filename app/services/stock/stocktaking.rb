module Stock
  # Stocktaking of consumables in one place (the main warehouse or another one), as in the reference:
  # an Excel sheet to count on (caxlsx), reading the counted sheet back for a preview (roo), and applying the counts.
  module Stocktaking
    COMMENT = "Інвентаризація".freeze # reports tell corrections from real use by this comment
    COLUMNS = ["ID", "Назва", "Категорія", "Од.", "За обліком", "Фактично"].freeze

    Count = Data.define(:item_id, :actual)
    Line = Data.define(:item_id, :name, :unit, :booked, :actual) do
      def difference = actual - booked
    end

    module_function

    # What the books say in the place: for the main warehouse the total minus what lies elsewhere.
    def booked(items, warehouse_id)
      located = StockLocation.where(item_id: items.map(&:id))
      located = located.where(warehouse_id:) if warehouse_id
      by_item = located.group(:item_id).sum(:quantity)
      items.to_h do |item|
        [item.id, warehouse_id ? by_item.fetch(item.id, 0).to_d : item.stock - by_item.fetch(item.id, 0)]
      end
    end

    def sheet(category_id:, warehouse_id:)
      items = StockItem.active.includes(:category).sorted
      items = items.in_category(category_id) if category_id
      items = items.to_a
      booked = booked(items, warehouse_id)
      package = Axlsx::Package.new
      package.workbook.add_worksheet(name: COMMENT) do |sheet|
        sheet.add_row COLUMNS
        items.each { |i| sheet.add_row [i.id, i.name, i.category&.name.to_s, i.unit, booked[i.id].to_f, nil] }
      end
      package.to_stream.read
    end

    # Reads the counted sheet: the ID column and the last ("Фактично"). A row with an empty count was not counted
    # and is skipped; so is the header row. Errors name the row number as Excel shows it.
    def parse(path)
      sheet = Roo::Excelx.new(path).sheet(0)
      counts = []
      errors = []
      (1..sheet.last_row.to_i).each do |row_number|
        id_text = sheet.cell(row_number, 1).to_s.strip.delete_suffix(".0")
        actual_text = sheet.cell(row_number, COLUMNS.size).to_s.strip
        next if (row_number == 1 && id_text.casecmp?("id")) || actual_text.empty?

        error = count_problem(row_number, id_text, actual_text, counts)
        error ? errors << error : counts << Count.new(item_id: id_text.to_i, actual: quantity(actual_text))
      end
      [counts, errors]
    rescue Zip::Error, ArgumentError, Roo::FileNotFound
      [[], ["Файл не схожий на аркуш Excel (.xlsx)."]]
    end

    def count_problem(row_number, id_text, actual_text, counts)
      return "Рядок #{row_number}: немає ID позиції або він не число." unless id_text.match?(/\A[1-9]\d*\z/)

      actual = quantity(actual_text)
      return "Рядок #{row_number}: «#{actual_text}» — не кількість." if actual.nil?
      unless !actual.negative? && BusinessText.scale_ok?(actual, StockItem::SCALE)
        return "Рядок #{row_number}: кількість має бути від 0, не більше #{StockItem::SCALE} знаків після коми."
      end

      "Рядок #{row_number}: позиція #{id_text} указана двічі." if counts.any? { |c| c.item_id == id_text.to_i }
    end

    # Excel in Ukrainian shows "12,5", and spaces separate thousands ("1 250").
    def quantity(text)
      cleaned = text.tr(",", ".").gsub(/[[:space:]]/, "")
      cleaned.match?(/\A[+-]?\d+(\.\d+)?\z/) ? BigDecimal(cleaned) : nil
    end
  end
end
