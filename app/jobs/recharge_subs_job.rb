class RechargeSubsJob < ApplicationJob
  queue_as :recharge_sub_down

  def perform(*args)
    # Do something later
    puts "Got here to pull down recharge subs"
    RechargeSubCache.get_all_subs
  end
end
