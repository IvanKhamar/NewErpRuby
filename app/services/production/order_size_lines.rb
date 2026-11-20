module Production
  # The model sizes an order's lines need: order line → product → production model (linked directly or through a
  # catalog category) → model size (linked to the line's option value, e.g. "M").
  class OrderSizeLines
    attr_reader :warnings

    def initialize(order_id)
      @order_id = order_id
      @warnings = []
    end

    # { size_id => quantity }
    def by_size
      @by_size ||= lines.each_with_object(Hash.new(0)) do |line, sizes|
        model = model_for(line)
        next if model.nil?

        size = model.sizes.find { |s| option_value_ids(line).include?(s.oc_option_value_id) }
        if size.nil?
          @warnings << "«#{line.name}»: розмір із замовлення не зв'язаний з розмірами моделі «#{model.name}», " \
                       "склад не змінено."
          next
        end
        sizes[size.id] += line.quantity
      end
    end

    private

    def lines
      @lines ||= OrderProduct.where(order_id: @order_id).order(:order_product_id).to_a
    end

    def option_value_ids(line) = option_values.fetch(line.id, [])

    # { order_product_id => [option_value_id] }: an order option points to a product option value, and a model
    # size to the shared option value ("M") behind it.
    def option_values
      @option_values ||= OrderOption.where(order_id: @order_id).joins(:product_option_value)
                                    .pluck(:order_product_id, "dd_product_option_value.option_value_id")
                                    .group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
    end

    def model_for(line)
      direct = direct_links[line.product_id]
      return direct if direct

      category_models(line.product_id).find { |link| link.matches?(line.name) }&.model
    end

    def direct_links
      @direct_links ||= ProductionProduct.where(product_id: lines.map(&:product_id))
                                         .joins(:model).merge(ProductionModel.active)
                                         .includes(model: :sizes)
                                         .to_h { |link| [link.product_id, link.model] }
    end

    def category_models(product_id)
      @category_links ||= ProductionCategory.joins(:model).merge(ProductionModel.active).includes(model: :sizes)
                                            .where(oc_category_id: product_categories.values.flatten.uniq).to_a
      ids = product_categories.fetch(product_id, [])
      @category_links.select { |link| ids.include?(link.oc_category_id) }
    end

    def product_categories
      @product_categories ||= ProductToCategory.where(product_id: lines.map(&:product_id))
                                               .pluck(:product_id, :category_id)
                                               .group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
    end
  end
end
