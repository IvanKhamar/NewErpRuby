module Orders
  # Did this customer cancel orders in the last years? Found by the phone digits, the full name or the e-mail.
  # (The reference also looks for many customers behind one IP address; that part is not ported, see PLAN.md.)
  class CustomerRiskCheck
    def initialize(telephone:, firstname:, lastname:, email:)
      @phone_key = CustomerRisk.phone_key(telephone)
      @firstname = firstname.to_s.strip
      @lastname = lastname.to_s.strip
      @email = email.to_s.strip
    end

    def call
      return CustomerRisk.of([]) if @phone_key.nil? && !name? && @email.empty?

      CustomerRisk.of(matching_orders)
    end

    private

    def name? = @firstname.present? && @lastname.present?

    def matching_orders
      since = ErpSettings.risk_lookback_years.years.ago
      candidates.where(date_added: since..).newest_first
                .pluck(:order_id, :order_status_id, :telephone, :firstname, :lastname, :email)
                .select { |row| same_customer?(*row.drop(2)) }
                .map { |row| row.first(2) }
    end

    # A wide SQL filter first; the exact comparison (only digits of the phone, names without case) runs in Ruby.
    def candidates
      scope = Order.placed.none
      scope = scope.or(Order.placed.where("telephone LIKE ?", "%#{phone_tail_pattern}")) if @phone_key
      scope = scope.or(Order.placed.where(firstname: @firstname, lastname: @lastname)) if name?
      scope = scope.or(Order.placed.where(email: @email)) if @email.present?
      scope
    end

    # Phones are stored any way ("+38 (067) 123-45-67"), so any characters may stand between the digits.
    def phone_tail_pattern = @phone_key.chars.join("%")

    def same_customer?(telephone, firstname, lastname, email)
      (@phone_key && CustomerRisk.phone_key(telephone) == @phone_key) ||
        (name? && firstname.strip.casecmp?(@firstname) && lastname.strip.casecmp?(@lastname)) ||
        (@email.present? && email.strip.casecmp?(@email))
    end
  end
end
