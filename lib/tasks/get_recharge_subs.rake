#get_recharge_subs.rake
namespace :recharge do

desc 'get all recharge ACTIVE subs'
task get_all_recharge_subs: :environment do |t|
    RechargeSubsJob.perform_later

end

desc 'get all recharge orders next month'
task get_all_recharge_orders_next_month: :environment do |t|
    RechargeOrdersJob.perform_later
end


end
