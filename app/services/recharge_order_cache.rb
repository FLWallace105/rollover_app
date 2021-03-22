# frozen_string_literal: true

module RechargeOrderCache
  PROPERTIES = %w[leggings tops sports_bra sports_jacket gloves product_collection].freeze
  BASE_URI = 'https://api.rechargeapps.com'

  class << self
    def get_all_orders_next_month
      Order.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('orders')

      orders = fetch_orders
      #puts "orders = #{orders.inspect}"
      Order.import(orders, batch_size: 50)
      puts "All done with fetching and creating orders"
    end

    private

    def fetch_orders(query = default_query)#, keep_ellie_picks = true)
      puts "Hi getting Recharge orders"
      page_size = 250
      url = "#{BASE_URI}/orders/count"
      response = HttpartyService.get(url, {}, query)
      orders_response = HttpartyService.parse_response(response)

      orders_size = orders_response['count'].to_i
      num_pages = (orders_size / page_size.to_f).ceil
      puts "we have #{orders_size} orders"

      query.merge!(limit: page_size)
      orders = []

      1.upto(num_pages) do |page|
        url = URI("#{BASE_URI}/orders")
        query.merge!(page: page)

        response = HttpartyService.get(url, {}, query)

        begin
          orders_response = HttpartyService.parse_response(response)['orders']
        rescue JSON::ParserError => e
          RechargeMailer.parsing_error_notifier(e, query, 'orders').deliver_now
          next
        end

        recharge_limit = response.headers['x-recharge-limit']
        next unless orders_response.present?

        orders_response.map do |order|
          properties = order.dig('line_items', 0, 'properties').to_a
          selected_properties = build_properties(properties)

          product_collection_name = selected_properties[:product_collection].to_s.downcase
          #next unless keep_product_collection?(product_collection_name, keep_ellie_picks)

          orders << build_default_order_attrs(order).merge(selected_properties)
        end
        #puts "orders = #{orders.inspect}"
        puts "Done loading page #{page}"
        BackgroundHelper.determine_limits(recharge_limit, 0.65)
      end
      puts "All done with download orders"
      orders.flatten
    end

    # def keep_product_collection?(product_collection_name, keep_ellie_picks)
    #     return true if product_collection_name.include?('ellie picks') && keep_ellie_picks

    #     !(product_collection_name.include?('ellie picks') || keep_ellie_picks)
    # end

    def default_query
      {
        status: 'queued',
        scheduled_at_min: Date.today.at_beginning_of_month.next_month.strftime("%Y-%m-%d"),
        scheduled_at_max: Date.today.end_of_month.next_month.strftime("%Y-%m-%d")
      }
    end

    def build_properties(properties)
      #puts "Here properties are #{properties}"
      selected_properties = {}
      upcased_properties = %w[leggings tops sports_bra sports_jacket gloves]

      properties.map do |property|
        property_name = property['name'].to_s.downcase.underscore

        if PROPERTIES.include?(property_name)
          property_value = property['value']
          value = upcased_properties.include?(property_name) ? property_value.to_s.upcase : property_value
          selected_properties[property_name.to_sym] = value
        end
      end
      #puts "selected_properties = #{selected_properties}"
      selected_properties
    end

    def build_default_order_attrs(order)
      {
        order_id: order.dig('id'),
        customer_id: order.dig('customer_id'),
        product_collection: nil,
        leggings: nil,
        tops: nil,
        sports_bra: nil,
        sports_jacket: nil,
        gloves: nil,
        subscription_id: order.dig('line_items', 0, 'subscription_id'),
        is_prepaid: order.dig('is_prepaid') == 1,
        scheduled_at: order.dig('scheduled_at'),
        created_at: order.dig('created_at'),
        updated_at: order.dig('updated_at'),
        email: order.dig('email'),
        first_name: order.dig('first_name'),
        last_name: order.dig('last_name'),
        line_items: order.dig('line_items'),
        status: order.dig('status'),
        order_type: order.dig('order_type'),
        total_line_items_price: order.dig('total_line_items_price').to_f
      }
    end

  end
end
