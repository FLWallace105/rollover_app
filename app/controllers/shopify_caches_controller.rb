# frozen_string_literal: true

class ShopifyCachesController < ApplicationController
  def refresh_all
    ShopifyPullAllJob.perform_later
    flash[:success] = 'Refreshing entire Shopify Cache. Please wait a couple minutes...'
    redirect_to root_path
  end
end
