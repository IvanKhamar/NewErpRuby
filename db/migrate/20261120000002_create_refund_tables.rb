# NewErpRuby's own tables for the refund recipient check (a module the other versions do not have yet).
# erp_ prefix like every own table of NewErp; InnoDB, so a refund and its check change together or not at all.
class CreateRefundTables < ActiveRecord::Migration[8.1]
  def change
    # Accounts whose holder we know (a local test register standing in for a bank's Confirmation of Payee service).
    create_table :erp_refund_known_account do |t|
      t.string :iban, limit: 34, null: false
      t.string :holder_name, null: false
      t.timestamps
      t.index :iban, unique: true
    end

    # Every check, whatever its result: the audit log of who checked which account and what the answer was.
    create_table :erp_refund_recipient_check do |t|
      t.integer :order_id
      t.string :iban, limit: 34, null: false
      t.string :entered_name, null: false
      t.string :result, limit: 20, null: false # match, close_match, no_match, account_not_found, invalid_iban
      t.string :suggested_name
      t.decimal :score, precision: 4, scale: 3
      t.integer :user_id, null: false
      t.datetime :created_at, null: false
      t.index :order_id
    end

    # A refund to a checked account. Made only after a match, or a close match the operator confirmed.
    create_table :erp_refund do |t|
      t.integer :order_id, null: false
      t.references :recipient_check, null: false, foreign_key: { to_table: :erp_refund_recipient_check }
      t.string :iban, limit: 34, null: false
      t.string :recipient_name, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.boolean :confirmed_close_match, null: false, default: false
      t.integer :user_id, null: false
      t.datetime :created_at, null: false
      t.index :order_id
    end
  end
end
