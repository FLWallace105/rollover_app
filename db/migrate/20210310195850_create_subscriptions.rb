class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.bigint :subscription_id
      t.bigint :address_id
      t.bigint :customer_id
      t.string :email
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :next_charge_scheduled_at
      t.string :product_title
      t.string :variant_title
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity
      t.string :status
      t.bigint :recharge_product_id
      t.bigint :shopify_product_id
      t.bigint :shopify_variant_id
      t.string :sku
      t.string :order_interval_unit
      t.string :order_interval_frequency
      t.string :charge_interval_frequency
      t.integer :order_day_of_month
      t.integer :order_day_of_week   
      t.jsonb :properties
      t.integer :expire_after_specific_number_of_charges 
      t.integer :has_queued_charges
      t.boolean :is_prepaid, default: false
      t.boolean :is_skippable, default: false 
      t.boolean :is_swappable, default: false
      t.integer :max_retries_reached
      t.boolean :sku_override, default: false
      t.string :product_collection
    end
    add_index :subscriptions, :subscription_id
  end

end
