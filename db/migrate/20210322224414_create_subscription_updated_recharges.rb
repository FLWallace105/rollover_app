class CreateSubscriptionUpdatedRecharges < ActiveRecord::Migration[6.1]
  def change
    create_table :subscription_updated_recharge do |t|
      t.bigint :subscription_id
      t.bigint :customer_id
      t.bigint :address_id
      t.string :email
      t.datetime :updated_at
      t.datetime :created_at
      t.datetime :next_charge_scheduled_at
      t.string :new_product_title
      t.string :status
      t.string :new_sku
      t.bigint :new_shopify_product_id
      t.bigint :new_shopify_variant_id
      t.string :new_product_collection
      t.boolean :is_prepaid, default: false
      t.jsonb :new_properties
      t.boolean :is_updated_on_recharge, default: false
      t.datetime :date_updated_on_recharge
    end
  end
end
