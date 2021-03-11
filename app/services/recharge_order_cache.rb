#recharge_order_cache.rb

module RechargeOrderCache
    BASE_URI = 'https://api.rechargeapps.com'
    PROPERTIES = %w[leggings tops sports_bra sports_jacket gloves product_collection].freeze

    def self.get_all_orders_next_month
        puts "Hi in the order self module"
        page_size = 250
        url = "#{BASE_URI}/orders/count"
        scheduled_at_min = Date.today.strftime("%Y-%m-%d")
        scheduled_at_max = Date.today.end_of_month.strftime("%Y-%m-%d")
        query = { status: 'queued', scheduled_at_min: scheduled_at_min, scheduled_at_max: scheduled_at_max }
        response = HttpartyService.get(url, {}, query)
        orders_response = HttpartyService.parse_response(response)

        orders_size = orders_response['count'].to_i
        num_pages = (orders_size / page_size.to_f).ceil
        puts "we have #{orders_size} orders"


    end



end