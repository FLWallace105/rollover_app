class CreateAllocationSizeTypes < ActiveRecord::Migration[6.1]
  def change
    create_table :allocation_size_types do |t|
      t.string :collection_name
      t.integer :collection_id
      t.string :collection_size_type
    end
  end
end
