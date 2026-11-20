module Refunds
  # Checks a refund recipient before any money goes out, like the UK's Confirmation of Payee:
  # the IBAN must be valid (format, country length, mod 97), then the name the customer gave is compared with the
  # holder of the account. Every check is written to the audit log, a failed one too.
  #
  # Results: match; close_match (with the holder's name as a hint, so the operator can confirm or ask again);
  # no_match; account_not_found (a valid IBAN we know no holder of). An invalid IBAN is refused with the reason.
  class CheckRecipient < ApplicationService
    MESSAGES = {
      PayeeName::MATCH => "Ім'я збігається з власником рахунку.",
      PayeeName::CLOSE_MATCH => "Ім'я схоже, але не збігається. Власник рахунку: %<holder>s. " \
                                "Повернення можливе лише з підтвердженням оператора.",
      PayeeName::NO_MATCH => "Ім'я не збігається з власником рахунку. Не повертайте кошти на цей рахунок.",
      RefundRecipientCheck::ACCOUNT_NOT_FOUND => "Рахунок не знайдено серед відомих: власника перевірити неможливо."
    }.freeze

    Outcome = Data.define(:check, :message)

    def initialize(iban:, name:, user:, order_id: nil)
      @iban = Iban.new(iban)
      @name = name.to_s.strip
      @user = user
      @order_id = order_id
    end

    def call
      return failure("Вкажіть ім'я або назву отримувача.") if @name.empty?
      return not_found("Замовлення #{@order_id} не знайдено.") if @order_id && !Order.exists?(order_id: @order_id)

      problem = @iban.problem
      if problem
        audit(RefundRecipientCheck::INVALID_IBAN)
        return failure(problem)
      end

      check = compare
      success(Outcome.new(check:, message: format(MESSAGES.fetch(check.result), holder: check.suggested_name.to_s)))
    end

    private

    def compare
      account = RefundKnownAccount.find_by(iban: @iban.value)
      return audit(RefundRecipientCheck::ACCOUNT_NOT_FOUND) if account.nil?

      outcome = PayeeName.compare(@name, account.holder_name)
      # The holder's name is shown only for a close match: it helps fix a typo, while for no match it would tell
      # anyone who types an IBAN whose account it is.
      suggestion = outcome.result == PayeeName::CLOSE_MATCH ? account.holder_name : nil
      audit(outcome.result, score: outcome.score, suggested_name: suggestion)
    end

    def audit(result, score: nil, suggested_name: nil)
      RefundRecipientCheck.create!(order_id: @order_id, iban: @iban.value[0, 34], entered_name: @name[0, 255], result:,
                                   score:, suggested_name:, user_id: @user.id, created_at: Time.current)
    end
  end
end
