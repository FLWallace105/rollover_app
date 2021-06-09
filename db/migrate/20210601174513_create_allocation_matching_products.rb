class CreateAllocationMatchingProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :allocation_matching_products do |t|
      t.string :product_title
      t.string :incoming_product_id
      t.string :outgoing_product_id
      t.integer :prod_type
    end
  end
end