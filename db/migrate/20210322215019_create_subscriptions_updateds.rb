class CreateSubscriptionsUpdateds < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions_updated do |t|
      t.bigint :subscription_id
      t.bigint :customer_id
      t.bigint :address_id
      t.string :email
      t.datetime :updated_at
      t.datetime :created_at
      t.datetime :next_charge_scheduled_at
      t.string :product_title
      t.string :status
      t.string :sku
      t.bigint :shopify_product_id
      t.bigint :shopify_variant_id
      t.string :product_collection
      t.boolean :is_prepaid, default: false
      t.jsonb :properties
      t.boolean :pushed_to_batch_request, default: false
      t.boolean :is_updated_on_recharge, default: false
      t.datetime :date_updated_on_recharge
    end
  end
end

