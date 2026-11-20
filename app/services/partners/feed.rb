require "builder" # Rails depends on it but does not load it outside views

module Partners
  # The XML feed (yml_catalog) a reseller partner's site downloads: our products in the partner's categories with
  # the partner's prices. Built like the reference (domain/partners.py build_feed): mapped categories give offers
  # with a markup; products mapped one by one give their own offers and are not repeated by their category.
  class Feed
    Offer = Data.define(:id, :price, :price_old, :category_id, :pictures, :model, :vendor_code, :name, :description,
                        :size, :barcode)
    Item = Data.define(:id, :model, :sku, :price, :name, :description, :category_ids, :images, :options)
    Variant = Data.define(:option_value_id, :name, :price)
    FeedCategory = Data.define(:id, :external_id, :name)

    def initialize(partner, shop_name: ENV.fetch("NEWERP_FEED_SHOP_NAME", "Vidro"),
                   company: ENV.fetch("NEWERP_FEED_COMPANY", ""), store_url: ENV.fetch("NEWERP_STORE_URL", ""))
      @partner = partner
      @shop_name = shop_name
      @company = company
      @store_url = store_url.present? && !store_url.end_with?("/") ? "#{store_url}/" : store_url
    end

    def to_xml(now: Time.current)
      categories, offers = build
      xml = Builder::XmlMarkup.new(indent: 2)
      xml.instruct! :xml, version: "1.0", encoding: "utf-8"
      xml.yml_catalog(date: now.strftime("%Y-%m-%d %H:%M")) do
        xml.shop do
          xml.name @shop_name
          xml.company @company
          xml.url @store_url
          xml.currencies { xml.currency(id: "UAH", rate: "1") }
          xml.categories do
            # The attribute is named after the first partner (EVA); its feed already reads this name.
            categories.each { |c| xml.category(c.name, { id: c.id, eva_id: c.external_id }.compact) }
          end
          xml.offers { offers.each { |offer| write_offer(xml, offer) } }
        end
      end
    end

    private

    def write_offer(xml, offer)
      xml.offer(id: offer.id, available: "true") do
        xml.price BusinessText.plain(offer.price)
        xml.price_old BusinessText.plain(offer.price_old) if offer.price_old
        xml.stock_quantity @partner.default_quantity
        xml.currencyId "UAH"
        xml.categoryId offer.category_id
        offer.pictures.each { |picture| xml.picture picture }
        xml.vendor @partner.vendor_name.to_s
        xml.article offer.model if offer.model.present?
        xml.vendorCode offer.vendor_code if offer.vendor_code
        xml.name_ua offer.name
        # Written as one raw line: Builder would indent the CDATA and add whitespace to the description.
        # CDATA cannot hold "]]>", so it is split across two sections.
        text = offer.description.gsub("]]>", "]]]]><![CDATA[>")
        xml << "        <description_ua><![CDATA[#{text}]]></description_ua>\n"
        xml.param(offer.size, name: "Розмір") if offer.size
        xml.param(offer.barcode, name: "Штрихкод")
      end
    end

    def build
      category_rows = @partner.category_maps.to_a
      map_index = category_rows.index_by { |row| key(row.category_id, row.size_name) }
      products = load_products(category_rows.map(&:category_id), @partner.product_maps.map(&:product_id))
      names = category_names(category_rows.map(&:category_id) + products.flat_map(&:category_ids))
      standalone, extra = product_offers(products.index_by(&:id), map_index, names)
      offers = category_offers(products, map_index, category_rows.to_set(&:category_id), standalone) +
               standalone.values
      categories = category_rows.map do |r|
        FeedCategory.new(id: r.id.to_s, external_id: r.external_id.presence,
                         name: r.external_name.presence || names[r.category_id].to_s)
      end
      categories += extra.sort.map { |id, name| FeedCategory.new(id: "p#{id}", external_id: nil, name:) }
      # The partner does not take offers without pictures, so they are skipped, as in the old feed.
      [categories, offers.select { |o| o.pictures.any? }]
    end

    def product_offers(products, map_index, names)
      standalone = {}
      extra = {}
      @partner.product_maps.each do |row|
        product = products[row.product_id] or next
        category_id = product.category_ids.min || 0
        category_row = resolve(map_index, category_id, row.size_name)
        extra[category_id] = names[category_id].to_s unless category_row
        feed_category = category_row ? category_row.id.to_s : "p#{category_id}"
        variants(product).each do |option, variant|
          next if option && row.size_name && option.name.strip != row.size_name

          own = mapped_offer(row, product, option, variant, feed_category)
          standalone[own.id] = own
        end
      end
      [standalone, extra]
    end

    # An offer of a product mapped on its own: the row's name and prices win over the catalog's.
    def mapped_offer(row, product, option, variant, category_id)
      offer(id: offer_id(product, option), product:, option:, variant:, category_id:,
            price: row.price_supply || (option ? option.price : product.price), price_old: row.price_sale,
            name: row.external_name.presence || display_name(product, option), vendor_code: row.external_id.presence)
    end

    def category_offers(products, map_index, mapped_ids, standalone)
      products.sort_by(&:id).flat_map do |product|
        category_id = product.category_ids.select { |c| mapped_ids.include?(c) }.min or next []
        variants(product).filter_map do |option, variant|
          row = resolve(map_index, category_id, option&.name)
          next if row.nil? || standalone.key?(offer_id(product, option))

          category_offer(row, product, option, variant)
        end
      end
    end

    # An offer from a mapped category: the catalog price with the category's markup in percent.
    def category_offer(row, product, option, variant)
      base = option ? option.price : product.price
      offer(id: offer_id(product, option).delete_prefix("p"), product:, option:, variant:, category_id: row.id.to_s,
            price: base * (1 + ((row.percent_supply || 0) / 100)),
            price_old: row.percent_sale && (base * (1 + (row.percent_sale / 100))),
            name: display_name(product, option), vendor_code: nil)
    end

    def offer_id(product, option) = option ? "p#{product.id}_#{option.option_value_id}" : "p#{product.id}"
    def display_name(product, option) = option ? "#{product.name} - #{option.name}".strip : product.name

    def variants(product)
      product.options.any? ? product.options.each_with_index.to_a : [[nil, 0]]
    end

    def offer(id:, product:, option:, variant:, price:, price_old:, category_id:, name:, vendor_code:)
      Offer.new(id:, price: price.round(2, half: :up), price_old: price_old&.round(2, half: :up), category_id:,
                pictures: product.images.compact_blank.map { |path| picture_url(path) }, model: product.model,
                vendor_code:, name:, description: plain_description(product.description), size: option&.name.presence,
                barcode: barcode(product.sku, product.id, variant))
    end

    def resolve(map_index, category_id, size_name)
      (size_name && map_index[key(category_id, size_name)]) || map_index[key(category_id, nil)]
    end

    def key(category_id, size_name) = "#{category_id}|#{size_name.to_s.strip}"

    # The old site's EAN-13: 482 + 4 digits of the SKU + 4 of the product id + the variant digit + the check digit.
    def barcode(sku, product_id, variant)
      sku_part = sku.to_s.match?(/\A\d+\z/) ? sku.to_s[0, 4].rjust(4, "0") : "0000"
      payload = "482#{sku_part}#{product_id.to_s[0, 4].rjust(4, '0')}#{variant % 10}"
      total = payload.chars.each_with_index.sum { |digit, i| digit.to_i * (i.even? ? 1 : 3) }
      payload + ((10 - (total % 10)) % 10).to_s
    end

    # OpenCart stores the description with escaped entities (&lt;p&gt;), so it is decoded twice, like the old feed;
    # paragraphs become line breaks and every tag goes (the partner wants plain text).
    def plain_description(text)
      decoded = CGI.unescapeHTML(CGI.unescapeHTML(text.to_s)).gsub(%r{</p>|<br\s*/?>}i, "\n")
      Rails::HTML5::FullSanitizer.new.sanitize(decoded).to_s.strip
    end

    def picture_url(path) = "#{@store_url}image/#{path.split('/').map { |s| ERB::Util.url_encode(s) }.join('/')}"

    def category_names(ids)
      CategoryDescription.localized.where(category_id: ids.uniq).pluck(:category_id, :name).to_h
    end

    def load_products(category_ids, product_ids)
      in_categories = ProductToCategory.where(category_id: category_ids).select(:product_id)
      rows = ::Product.where(status: true).where(product_id: product_ids)
                      .or(::Product.where(status: true, product_id: in_categories))
                      .includes(:description).to_a
      ids = rows.map(&:id)
      categories = ProductToCategory.where(product_id: ids).order(:category_id).pluck(:product_id, :category_id)
                                    .group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
      images = ProductImage.where(product_id: ids).order(:sort_order, :product_image_id).pluck(:product_id, :image)
                           .group_by(&:first).transform_values { |pairs| pairs.map(&:last) }
      options = feed_options(ids)
      rows.map do |p|
        Item.new(id: p.id, model: p.model.to_s, sku: p.sku.to_s, price: p.price, name: p.name,
                 description: p.description&.description.to_s, category_ids: categories.fetch(p.id, []),
                 images: [p.image.presence, *images.fetch(p.id, [])].compact, options: options.fetch(p.id, []))
      end
    end

    def feed_options(ids)
      ProductOptionValue.where(product_id: ids).includes(:value_description).order(:option_value_id,
                                                                                   :product_option_value_id)
                        .group_by(&:product_id)
                        .transform_values do |values|
        values.map do |v|
          Variant.new(option_value_id: v.option_value_id, name: v.value_name, price: v.price)
        end
      end
    end
  end
end
