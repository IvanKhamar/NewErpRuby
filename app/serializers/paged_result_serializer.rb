# PagedResult<T> of the contract: the page, its size and the totals.
class PagedResultSerializer
  def initialize(items:, page:, page_size:, total_count:, item_serializer:)
    @items = items
    @page = page
    @page_size = page_size
    @total_count = total_count
    @item_serializer = item_serializer
  end

  def serialize
    { items: @item_serializer.new(@items).to_h, page: @page, pageSize: @page_size, totalCount: @total_count,
      totalPages: (@total_count.to_f / @page_size).ceil }.to_json
  end
end
