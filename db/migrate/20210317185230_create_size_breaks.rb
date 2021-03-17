class CreateSizeBreaks < ActiveRecord::Migration[6.1]
  def change
    create_table :size_breaks do |t|
      t.boolean :use_size_breaks, default: false
      t.boolean :use_gloves, default: false
      t.boolean :use_leggings, default: true
      t.boolean :use_sports_bra, default: true
      t.boolean :use_tops, default: true
      t.boolean :use_sports_jacket, default: false
      

      t.timestamps
    end
  end
end
