module Reports
  # Sales by period: orders, pieces and money per day, week (from Monday), month or year, within [from; to].
  # Without a status: every placed order except cancelled ones, as the old report did. Empty periods are not shown.
  class Sales < ApplicationService
    GROUPS = { "day" => :day, "week" => :week, "month" => :month, "year" => :year,
               "0" => :day, "1" => :week, "2" => :month, "3" => :year }.freeze
    MAX_DAYS = 3 * 366

    Row = Data.define(:start, :finish, :orders, :products, :total)
    Report = Data.define(:from, :to, :rows) do
      def orders = rows.sum(&:orders)
      def products = rows.sum(&:products)
      def total = rows.sum(BigDecimal(0), &:total)
    end

    def initialize(from:, to:, status_id:, group:)
      @from = from
      @to = to
      @status_id = status_id
      @group = GROUPS[group.to_s.downcase] || raise(DomainError, "Невідоме групування «#{group}».")
    end

    def call
      today = Date.current
      from = @from || today.beginning_of_month # by default the current month, as in the old reports
      to = @to || today
      return failure("Дата «по» раніша за дату «з».") if to < from
      return failure("Період звіту — не більше трьох років.") if (to - from).to_i > MAX_DAYS

      success(Report.new(from:, to:, rows: rows(from, to)))
    end

    private

    def rows(from, to)
      orders = scope(from, to)
      pieces = OrderProduct.where(order_id: orders.select(:order_id)).group(:order_id).sum(:quantity)
      buckets = orders.pluck(:order_id, :date_added, :total).group_by { |_, added, _| period_start(added.to_date) }
      buckets.sort.map do |start, bucket|
        Row.new(start: [start, from].max, finish: [period_end(start), to].min, orders: bucket.size,
                products: bucket.sum { |id, _, _| pieces.fetch(id, 0).to_i }, total: bucket.sum(BigDecimal(0), &:last))
      end
    end

    def scope(from, to)
      orders = Order.placed.added_from(from).added_to(to)
      @status_id ? orders.with_status(@status_id) : orders.where.not(order_status_id: ErpSettings.cancelled_status_id)
    end

    # A week starts on Monday, as in Ukraine (the old report used MySQL WEEK(), which counts from Sunday).
    def period_start(day) = day.public_send(:"beginning_of_#{@group}")
    def period_end(start) = start.public_send(:"end_of_#{@group}")
  end
end
