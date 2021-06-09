class CreateAllocationCollections < ActiveRecord::Migration[6.1]
  def change
    create_table :allocation_collections do |t|
      t.string :name
      t.bigint :collection_id
      t.bigint :product_id
    end
  end
end
