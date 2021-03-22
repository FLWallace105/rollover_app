class CreateOrderUpdatedRecharges < ActiveRecord::Migration[6.1]
  def change
    create_table :order_updated_recharge do |t|
      t.bigint :order_id
      t.bigint :subscription_id
      t.string :new_product_collection
      t.string :new_leggings
      t.string :new_tops
      t.string :new_ports_bra
      t.string :new_sports_jacket
      t.string :new_gloves
      t.string :charge_status
      t.integer :address_is_active
      t.string :status
      t.string :order_type
      t.datetime :scheduled_at
      t.bigint :customer_id
      t.string :first_name
      t.string :last_name
      t.boolean :is_prepaid, default: false
      t.datetime :created_at
      t.datetime :updated_at
      t.string :email
      t.jsonb :line_items
      t.decimal :total_price, precision: 10, scale: 2
      t.boolean :is_updated_on_recharge, default: false
      t.datetime :date_updated_on_recharge
    end
  end
end
