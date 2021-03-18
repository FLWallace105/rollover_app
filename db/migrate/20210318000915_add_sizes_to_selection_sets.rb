class AddSizesToSelectionSets < ActiveRecord::Migration[6.1]
  def change
  	  add_column :selection_sets, :leggings, :string
      add_column :selection_sets, :tops, :string
      add_column :selection_sets, :sports_bra, :string
      add_column :selection_sets, :sports_jacket, :string
      add_column :selection_sets, :gloves, :string
  end
end
