class RechargeOrdersJob < ApplicationJob
  queue_as :order_queue

  def perform(*args)
    puts "Starting order job."
    RechargeOrderCache.get_all_orders_next_month
  end
end
