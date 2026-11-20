module Orders
  # Reward points of an order for the customer, added and taken back by hand, like the buttons of the old admin's
  # order page. A second press adds nothing. Points move money, so each change goes to the audit log.
  class Reward < ApplicationService
    Credits = Data.define(:order_id, :customer_id, :reward_points, :reward_added, :affiliate_id, :commission,
                          :commission_added)

    def self.credits(order_id)
      order = Order.find_by(order_id:)
      return nil if order.nil?

      Credits.new(order_id:, customer_id: order.customer_id,
                  reward_points: OrderProduct.where(order_id:).sum(:reward).to_i,
                  reward_added: CustomerReward.given.exists?(order_id:),
                  affiliate_id: order.affiliate_id, commission: order.commission,
                  commission_added: CustomerTransaction.exists?(order_id:))
    end

    # action: :add or :remove
    def initialize(order_id:, action:, user:)
      @order_id = order_id
      @action = action
      @user = user
    end

    def call
      credits = self.class.credits(@order_id)
      return not_found("Замовлення #{@order_id} не знайдено.") if credits.nil?

      @action == :add ? add(credits) : remove(credits)
      success(self.class.credits(@order_id))
    end

    private

    def add(credits)
      if credits.customer_id.zero?
        raise DomainError, "Замовлення оформлене без облікового запису клієнта: бонуси нікому нарахувати."
      end
      raise DomainError, "Товари замовлення не дають бонусних балів." unless credits.reward_points.positive?
      return if credits.reward_added

      CustomerReward.create!(customer_id: credits.customer_id, order_id: @order_id, points: credits.reward_points,
                             description: "Замовлення №#{@order_id}", date_added: Time.current)
      audit("reward added: order #{@order_id}, customer #{credits.customer_id}, points #{credits.reward_points}")
    end

    # Only the points the order gave (positive rows); points spent on it stay.
    def remove(credits)
      return unless credits.reward_added

      CustomerReward.given.where(order_id: @order_id).delete_all
      audit("reward removed: order #{@order_id}, customer #{credits.customer_id}")
    end

    def audit(text) = Rails.logger.info("[audit] #{text}, by user #{@user.id}")
  end
end
