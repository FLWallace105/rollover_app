#get_recharge_subs.rake
namespace :recharge do

desc 'get all recharge ACTIVE subs'
task get_all_recharge_subs: :environment do |t|
    RechargeSubsJob.perform_later

end


end
