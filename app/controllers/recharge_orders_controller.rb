class RechargeOrdersController < ApplicationController
    def index
        RechargeOrdersJob.perform_later
        flash[:success] = 'Pull recharge orders. Please wait a couple minutes...'
        redirect_to root_path
    end
end
