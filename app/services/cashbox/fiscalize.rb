module Cashbox
  # Fiscalizes again a receipt Checkbox did not accept ("Створити чек" in the old site's list). The cashier must
  # have Checkbox keys and an open shift.
  class Fiscalize < ApplicationService
    def initialize(cheque_id:, client: Checkbox::Client.build)
      @cheque_id = cheque_id
      @client = client
    end

    def call
      cheque = Cheque.includes(:cashier, order: :products).find_by(cheque_id: @cheque_id)
      return not_found("Чек #{@cheque_id} не знайдено.") if cheque.nil?
      return failure("Чек уже фіскалізовано.") if cheque.fiscalized?
      return failure("Замовлення #{cheque.order_id} чека не знайдено.") if cheque.order.nil?

      cashier = cheque.cashier
      unless @client.usable?(cashier.id)
        return failure("Для касира «#{cashier.name}» не задано ключі Checkbox (NEWERP_CHECKBOX_CASHIERS).")
      end

      shift = cashier.work_shifts.open.order(date_start: :desc).first
      return failure("У касира «#{cashier.name}» немає відкритої зміни. Спершу відкрийте зміну.") if shift.nil?

      receipt = FiscalReceipt.build(order: cheque.order, cashier_name: cashier.name, total: cheque.sum)
      cheque.update!(checkbox_id: @client.sell(cashier.id, receipt), cashbox_work_shift_id: shift.id)
      success(cheque)
    rescue Checkbox::Client::Error => e
      failure(e.message)
    end
  end
end
