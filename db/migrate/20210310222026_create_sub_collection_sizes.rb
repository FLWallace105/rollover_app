class CreateSubCollectionSizes < ActiveRecord::Migration[6.1]
  def change
    create_table :sub_collection_sizes do |t|
      t.bigint :subscription_id
      t.string :product_collection
      t.string :gloves
      t.string :leggings
      t.string :tops
      t.string :sports_bra
      t.string :sports_jacket
      t.datetime :created_at
      t.datetime :updated_at
    end
    add_index :sub_collection_sizes, :subscription_id
  end
end
