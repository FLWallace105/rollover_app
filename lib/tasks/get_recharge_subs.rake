#get_recharge_subs.rake
namespace :recharge_subs do

desc 'get all recharge ACTIVE subs'
task stub: :environment do |t|
    RechargeSubsJob.perform_later

end


end
