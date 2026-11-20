module Refunds
  # A refund to the account of a recipient check. Allowed only after a match, or after a close match the operator
  # explicitly confirmed; never after no_match or account_not_found. Not more than the order total minus what was
  # already refunded. The check row is locked, so two clicks cannot make two refunds that together exceed the order.
  class Create < ApplicationService
    def initialize(order_id:, check_id:, amount:, confirm_close_match:, user:)
      @order_id = order_id
      @check_id = check_id
      @amount = amount
      @confirm = confirm_close_match
      @user = user
    end

    def call
      order = Order.find_by(order_id: @order_id)
      return not_found("Замовлення #{@order_id} не знайдено.") if order.nil?

      Refund.transaction do
        check = RefundRecipientCheck.lock.find_by(id: @check_id)
        return not_found("Перевірку отримувача #{@check_id} не знайдено.") if check.nil?

        problem = check_problem(check) || amount_problem(order)
        return failure(problem) if problem

        success(Refund.create!(order_id: order.id, recipient_check: check, iban: check.iban,
                               recipient_name: check.entered_name, amount: @amount.round(2, half: :even),
                               confirmed_close_match: check.close_match?, user_id: @user.id, created_at: Time.current))
      end
    end

    private

    def check_problem(check)
      return "Перевірка отримувача стосується іншого замовлення." if check.order_id != @order_id
      return nil if check.match?
      return nil if check.close_match? && @confirm
      return "Ім'я лише схоже на власника рахунку: підтвердіть повернення явно." if check.close_match?

      "Повернення можливе лише після збігу імені з власником рахунку (результат перевірки: #{check.result})."
    end

    def amount_problem(order)
      return "Сума повернення має бути більшою за нуль." unless @amount&.positive?

      refunded = Refund.where(order_id: order.id).sum(:amount)
      left = order.total - refunded
      return nil if @amount <= left

      "Сума повернення більша за залишок замовлення (#{BusinessText.plain(left)} грн)."
    end
  end
end
