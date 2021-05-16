FactoryBot.define do
  factory :batch_task do
    num_tasks_this_batch { 10000 }
    sent_to_processing { false }
    batch_filled_with_tasks { false }
  end
end
