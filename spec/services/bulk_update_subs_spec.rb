require 'rails_helper'

RSpec.describe BulkUpdateSubs do

  describe '#determine_batches_needed' do
    it do
      allow(SubscriptionsUpdated).to receive(:count) { 1000 }

      expect(BulkUpdateSubs.determine_batches_needed).to eq(1)
    end
  end

  describe '#create_batch_task' do
    it do
      allow(HttpartyService).to receive(:post) { OpenStruct.new(parsed_response: { 'async_batch' => { 'id' => 101010 } })}

      expect(BulkUpdateSubs.create_batch_task).to eq(101010)
    end
  end

  describe '#bulk_update_subs' do
    it 'set num_tasks_this_batch to 0 ' do
      batch_task = create(:batch_task, sent_to_processing: false, batch_filled_with_tasks: false)

      BulkUpdateSubs.bulk_update_subs
      expect(batch_task.reload.num_tasks_this_batch).to eq(0)
    end
  end

  describe '#bulk_update_task' do
    context 'when not sending to recharge' do
      let!(:batch_task) { create(:batch_task, sent_to_processing: false, batch_filled_with_tasks: false, num_tasks_this_batch: 10000) }
      let(:product_collection_names) { [] }
      before do
        subscription_updated = create(:subscriptions_updated, pushed_to_batch_request: false, shopify_product_id: 10)
        current_product = create(:current_product, prod_id_value: subscription_updated.shopify_product_id, next_month_prod_id: 20)
        create(:update_product, shopify_product_id: current_product.next_month_prod_id)
      end
      it do
        BulkUpdateSubs.bulk_update_task(batch_task.batch_id, product_collection_names)
        expect(batch_task.reload.batch_filled_with_tasks).to eq(true)
      end
    end

    context 'when sending to recharge' do
      let!(:batch_task) { create(:batch_task, sent_to_processing: false, batch_filled_with_tasks: false, num_tasks_this_batch: 9999) }
      let(:product_collection_names) { [] }
      before do
        subscription_updated = create(:subscriptions_updated, pushed_to_batch_request: false, shopify_product_id: 10)
        current_product = create(:current_product, prod_id_value: subscription_updated.shopify_product_id, next_month_prod_id: 20)
        create(:update_product, shopify_product_id: current_product.next_month_prod_id)

        allow(HttpartyService).to receive(:post) { OpenStruct.new }
      end
      it do
        BulkUpdateSubs.bulk_update_task(batch_task.batch_id, product_collection_names)
        expect(batch_task.reload.batch_filled_with_tasks).to eq(true)
      end
    end
  end

  describe '#send_task_process' do
    it do
      batch_task = create(:batch_task, batch_id: 10, sent_to_processing: false, batch_filled_with_tasks: false)
      allow(HttpartyService).to receive(:post) { OpenStruct.new }

      BulkUpdateSubs.send_task_process(batch_task.batch_id)
      expect(batch_task.reload.sent_to_processing).to eq(true)
    end
  end

  describe '#get_task_info' do
    it do
      allow(HttpartyService).to receive(:get) { OpenStruct.new }
      allow_any_instance_of(OpenStruct).to receive(:inspect).and_return(true)

      BulkUpdateSubs.get_task_info(10)
    end
  end

  describe '#detailed_task_info' do
    let(:batch_task) { create(:batch_task, sent_to_processing: false, batch_filled_with_tasks: false, num_tasks_this_batch: 10000, batch_id: 10) }
    let(:async_batch_tasks) do
      [
        {
          'result'=> {
            'status_code' => status_code,
            'output' => {
              'subscriptions' => 'subscriptions'
            }
          }
        }
      ]
    end

    before do
      allow(HttpartyService).to receive(:get).with("https://api.rechargeapps.com/async_batches/#{batch_task.batch_id}", {} , {}) { OpenStruct.new(parsed_response: {'async_batch'=>{'total_task_count'=>10}} ) }
      allow(HttpartyService).to receive(:get).with("https://api.rechargeapps.com/async_batches/#{batch_task.batch_id}/tasks", {} , { limit: 250, page: 1 }) { OpenStruct.new(parsed_response: {'async_batch_tasks'=>async_batch_tasks } ) }
    end

    context 'when request was successfull' do
      let(:status_code) { 200 }
      it do
        expect { BulkUpdateSubs.detailed_task_info(batch_task.batch_id) }.to output(/subscriptions/).to_stdout
      end
    end

    context 'when request was not successfull' do
      let(:status_code) { 404 }
      it do
        expect { BulkUpdateSubs.detailed_task_info(batch_task.batch_id) }.to output(/PROBLEM -->/).to_stdout
      end
    end
  end
end