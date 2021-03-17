class CreateInventorySizes < ActiveRecord::Migration[6.1]
  def change
    create_table :inventory_sizes do |t|
      t.string :product_type
      t.string :product_size
      t.integer :inventory_avail
      t.integer :inventory_assigned

      t.timestamps
    end
  end
end
