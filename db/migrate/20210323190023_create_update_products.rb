class CreateUpdateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :update_products do |t|
      t.string :sku
      t.string :product_title
      t.bigint :shopify_product_id
      t.bigint :shopify_variant_id
      t.string :product_collection

      t.timestamps
    end
  end
end
