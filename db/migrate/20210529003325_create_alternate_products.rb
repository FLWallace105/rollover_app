class CreateAlternateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :alternate_products do |t|
      t.string :product_title
      t.bigint :product_id
      t.bigint :variant_id
      t.string :sku
      t.string :product_collection
    end
  end
end
