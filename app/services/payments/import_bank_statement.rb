module Payments
  # Loads the incoming payments of a period (by default yesterday and today) from PrivatBank, without LiqPay
  # payouts (those are matched through LiqPay). A row already loaded (the same bank id) is skipped, so importing
  # again is safe. (The reference then links payments to orders automatically; that part is not ported.)
  class ImportBankStatement < ApplicationService
    MAX_DAYS = 31

    Summary = Data.define(:client_configured, :fetched, :added, :skipped)

    def initialize(from:, to:, client: Privatbank::Client.build)
      @from = from
      @to = to
      @client = client
    end

    def call
      return success(Summary.new(client_configured: false, fetched: 0, added: 0, skipped: 0)) unless @client.configured?

      finish = @to || Date.current
      start = @from || (finish - 1)
      return failure("Початок періоду пізніше за кінець.") if start > finish
      return failure("Завантажувати можна не більше ніж #{MAX_DAYS} днів за раз.") if (finish - start).to_i > MAX_DAYS

      transactions = @client.fetch(start, finish)
      added = save_new(transactions)
      success(Summary.new(client_configured: true, fetched: transactions.size, added:,
                          skipped: transactions.size - added))
    rescue Privatbank::Client::Error => e
      failure(e.message)
    end

    private

    def save_new(transactions)
      incoming = transactions.select { |txn| txn.incoming && txn.id.present? }
                             .select { |txn| txn.purpose.downcase.exclude?("liqpay") }.uniq(&:id)
      known = BankPayment.where(appcode: incoming.map(&:id)).pluck(:appcode)
      fresh = incoming.reject { |t| known.include?(t.id) }
      fresh.each { |t| BankPayment.create!(attributes(t)) }
      fresh.size
    end

    def attributes(txn)
      { appcode: txn.id, card: txn.account, amount: BankPayment.money_text(txn.amount),
        cardamount: BankPayment.money_text(txn.amount), rest: BankPayment.money_text(txn.balance || 0),
        description: describe(txn), terminal: txn.payer[0, 255], trandate: txn.date, trantime: txn.time,
        show_status: true, order_id: 0 }
    end

    def describe(txn)
      [txn.purpose, txn.payer_account.presence && "Рахунок: #{txn.payer_account}",
       txn.payer_bank_code.presence && "МФО: #{txn.payer_bank_code}",
       txn.payer_tax_code.presence && "ЄДРПОУ: #{txn.payer_tax_code}"].compact_blank.join("\n")
    end
  end
end
