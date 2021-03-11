#recharge_order_cache.rb

module RechargeOrderCache
    BASE_URI = 'https://api.rechargeapps.com'
    PROPERTIES = %w[leggings tops sports_bra sports_jacket gloves product_collection].freeze

    def self.get_all_orders_next_month
        puts "Hi in the order self module"
        page_size = 250
        url = "#{BASE_URI}/orders/count"
        scheduled_at_min = Date.today.at_beginning_of_month.next_month.strftime("%Y-%m-%d")
        scheduled_at_max = Date.today.end_of_month.next_month.strftime("%Y-%m-%d")
        puts "scheduled_at_min = #{scheduled_at_min}, scheduled_at_max = #{scheduled_at_max}"
        query = { status: 'queued', scheduled_at_min: scheduled_at_min, scheduled_at_max: scheduled_at_max }
        response = HttpartyService.get(url, {}, query)
        orders_response = HttpartyService.parse_response(response)

        orders_size = orders_response['count'].to_i
        num_pages = (orders_size / page_size.to_f).ceil
        puts "we have #{orders_size} orders"

        query.merge!(limit: page_size)

        1.upto(num_pages) do |page|
            url = URI("#{BASE_URI}/orders")
            query.merge!(page: page)
    
            response = HttpartyService.get(url, {}, query)
            orders_response = HttpartyService.parse_response(response)['orders']
            #puts orders_response.inspect

            orders_response.each do |order|
                puts "----------"
                puts order.inspect
                puts "----------"

            end

            recharge_limit = response.headers['x-recharge-limit']

            puts "Done loading page #{page}"
            BackgroundHelper.determine_limits(recharge_limit, 0.65)

        end
        puts "All done with download orders"

    end



end