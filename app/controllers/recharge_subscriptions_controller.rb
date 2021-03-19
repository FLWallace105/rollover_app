class RechargeSubscriptionsController < ApplicationController
    def index
        RechargeSubsJob.perform_later
        flash[:success] = 'Pull recharge subscriptions. Please wait a couple minutes...'
        redirect_to root_path
      end
end
