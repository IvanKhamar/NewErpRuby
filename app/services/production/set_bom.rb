module Production
  # Replaces a BOM: the cutting BOM of a part (kind :component) or the sewing BOM of a model (kind :sewn).
  # The old module rewrites a BOM by DELETE + INSERT; so does this, in one transaction.
  class SetBom < ApplicationService
    Row = Data.define(:size_id, :component_id, :item_id, :qty_per_unit)

    def initialize(kind:, id:, rows:)
      @kind = kind
      @id = id
      @rows = rows
    end

    def call
      @kind == :component ? set_component_bom : set_sewn_bom
    end

    private

    def set_component_bom
      component = ProductionComponent.find_by(component_id: @id)
      return not_found("Деталь #{@id} не знайдено.") if component.nil?

      model = ProductionModel.active.find_by(production_id: component.production_id)
      return not_found("Модель #{component.production_id} не знайдено.") if model.nil?

      size_ids = model.sizes.map(&:id)
      @rows.each do |row|
        unless row.qty_per_unit.positive?
          raise DomainError,
                "Кількість розхідника на одну деталь має бути більшою за нуль."
        end
        if row.size_id && size_ids.exclude?(row.size_id)
          raise DomainError,
                "Розмір #{row.size_id} не належить моделі цієї деталі."
        end
      end
      require_unique(@rows.map { |r| [r.size_id, r.item_id] }, "Специфікація крою містить повторювані рядки.")
      require_items(@rows.map(&:item_id))
      replace(component.bom_lines) do |row|
        { size_id: row.size_id, item_id: row.item_id, qty_per_unit: row.qty_per_unit }
      end
    end

    def set_sewn_bom
      model = ProductionModel.active.find_by(production_id: @id)
      return not_found("Модель #{@id} не знайдено.") if model.nil?

      component_ids = model.components.map(&:id)
      @rows.each do |row|
        if row.component_id.nil? == row.item_id.nil?
          raise DomainError, "Рядок специфікації пошиву: вкажіть або деталь крою, або розхідник."
        end
        raise DomainError, "Кількість на один виріб має бути більшою за нуль." unless row.qty_per_unit.positive?

        model.require_size(row.size_id) if row.size_id
        if row.component_id && component_ids.exclude?(row.component_id)
          raise DomainError, "Деталь #{row.component_id} не належить цій моделі."
        end
      end
      require_unique(@rows.map do |r|
        [r.size_id, r.component_id, r.item_id]
      end, "Специфікація пошиву містить повторювані рядки.")
      require_items(@rows.filter_map(&:item_id))
      replace(model.sewn_bom_lines) do |row|
        { size_id: row.size_id, component_id: row.component_id, item_id: row.item_id, qty_per_unit: row.qty_per_unit }
      end
    end

    def replace(association, &)
      ApplicationRecord.transaction do
        association.scope.delete_all # a plain DELETE; has_many#delete_all would only nullify the key
        @rows.each { |row| association.create!(yield(row)) }
      end
      success
    end

    def require_unique(keys, message)
      raise DomainError, message if keys.uniq.size != keys.size
    end

    def require_items(item_ids)
      missing = item_ids.uniq - StockItem.where(item_id: item_ids).pluck(:item_id)
      raise DomainError, "Розхідників #{missing.join(', ')} немає на складі." if missing.any?
    end
  end
end
