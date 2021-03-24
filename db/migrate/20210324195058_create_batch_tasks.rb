class CreateBatchTasks < ActiveRecord::Migration[6.1]
  def change
    create_table :batch_tasks do |t|
      t.bigint :batch_id
      t.bigint :num_tasks_this_batch
      t.boolean :sent_to_processing, default: false
      t.boolean :batch_filled_with_tasks, default: false

      t.timestamps
    end
  end
end
