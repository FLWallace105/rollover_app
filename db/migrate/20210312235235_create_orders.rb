class CreateOrders < ActiveRecord::Migration[6.1]
  def change
    create_table :orders do |t|
      t.bigint :order_id
      t.bigint :subscription_id
      t.bigint :customer_id
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :product_collection
      t.string :leggings
      t.string :tops
      t.string :sports_bra
      t.string :sports_jacket
      t.string :gloves
      t.boolean :is_prepaid, default: false
      t.string :status
      t.integer :address_is_active
      t.string :order_type
      t.decimal :total_line_items_price, precision: 10, scale: 2
      t.datetime :scheduled_at
      t.timestamps #the date/time stamps for the orders refer to the values passed in from
      # the original order respectively, not the date/time the order is download.
      t.jsonb :line_items
    end
    add_index :orders, :order_id
    add_index :orders, :customer_id
  end
end

