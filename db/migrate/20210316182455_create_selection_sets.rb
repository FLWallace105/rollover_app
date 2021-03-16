class CreateSelectionSets < ActiveRecord::Migration[6.1]
  def change
    create_table :selection_sets do |t|
      t.integer :selection_set_type, default: 0
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :ignore_dates_use_nulls, default: :false
      t.boolean :allow_ellie_picks_in_selection_set, default: :false
      t.boolean :use_size_breaks, default: :false
      t.boolean :use_gloves_in_size_breaks, default: :false


      t.timestamps
    end
  end
end
