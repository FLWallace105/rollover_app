class CreateCurrentProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :current_products do |t|
      t.string :prod_id_key
      t.string :prod_id_value
      t.string :next_month_prod_id
      t.boolean :prepaid, default: false

      t.timestamps
    end
  end
end
