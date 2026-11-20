module PreOrders
  # Takes what the storefront sold ahead off the pre-order limits (hourly by SettlePreOrdersJob, or by hand).
  #
  # dd_product_option_value is MyISAM: no transactions, no row locks. So each size is one UPDATE guarded by the old
  # values (compare-and-set): if the storefront sold more in the meantime, the row stays and is settled next time.
  class Settle < ApplicationService
    def call
      changed = ProductOptionValue.sold_ahead.pluck(:product_option_value_id, :quantity, :pre_order_quantity)
                                  .sum { |id, quantity, quota| settle_one(id, quantity, quota) }
      success(changed)
    end

    private

    def settle_one(id, quantity, quota)
      new_quantity, new_quota = ProductOptionValue.settled(quantity, quota)
      # update_all on purpose: one guarded UPDATE is the whole point (compare-and-set), there are no validations.
      ProductOptionValue.where(product_option_value_id: id, quantity:, pre_order_quantity: quota)
                        .update_all(quantity: new_quantity, pre_order_quantity: new_quota) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
