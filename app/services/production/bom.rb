module Production
  # The old module's rule for BOM rows: the effective rows for a size, one per key (a consumable or a part).
  # A row for this very size wins over a general row (size_id NULL).
  module Bom
    module_function

    # rows: BOM lines; key: :item_id or :component_id
    def resolve(rows, size_id, key)
      rows.each_with_object({}) do |row, effective|
        id = row.public_send(key)
        next if id.nil?

        if row.size_id == size_id
          effective[id] = row
        elsif row.size_id.nil?
          effective[id] ||= row
        end
      end.values
    end
  end
end
