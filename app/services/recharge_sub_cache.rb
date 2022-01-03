

module RechargeSubCache
    BASE_URI = 'https://api.rechargeapps.com'
    PROPERTIES = %w[leggings tops sports_bra sports_jacket gloves product_collection].freeze

    def self.get_all_subs
        puts "Hi in the self module"
        Subscription.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions')
        SubCollectionSize.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('sub_collection_sizes')
        page_size = 250
        url = "#{BASE_URI}/subscriptions/count"
        query = { status: 'ACTIVE' }
        response = HttpartyService.get(url, {}, query)
        subs_response = HttpartyService.parse_response(response)
        puts subs_response.inspect
        num_subs = subs_response['count'].to_i
        num_pages = (num_subs / page_size.to_f).ceil

        new_query = {status: 'ACTIVE', limit: page_size }
     

      1.upto(num_pages) do |page|
        url = URI("#{BASE_URI}/subscriptions")
        new_query.merge!(page: page)

        response = HttpartyService.get(url, {}, new_query)
        subs_response = HttpartyService.parse_response(response)['subscriptions']
        #puts subs_response
        temp_subs_array = []
        temp_sub_collection_sizes_array = []
        
        subs_response.each do |mysub|
            temp_sub = process_sub(mysub)
            temp_subs_array.push(temp_sub)
            temp_sub_collection_sizes = process_properties(mysub)
            temp_sub_collection_sizes_array.push(temp_sub_collection_sizes)
        end
        #bulk insert this page
        puts "Starting Bulk insert"
        puts temp_subs_array.inspect
        puts "_______________________"
        result = Subscription.insert_all(temp_subs_array)
        puts result.inspect
        puts temp_sub_collection_sizes_array.inspect
        new_result = SubCollectionSize.insert_all(temp_sub_collection_sizes_array)
        puts new_result.inspect
        

        

        recharge_limit = response.headers['x-recharge-limit']

        puts "Done loading page #{page}"
        BackgroundHelper.determine_limits(recharge_limit, 0.65)



      end
      puts "All done with subs"
      #puts temp_subs.inspect
      

    end

    private

    def self.process_properties(sub)
        selected_properties = {}
        upcased_properties = %w[leggings tops sports_bra sports_jacket gloves]
        all_properties = %w[leggings tops sports_bra sports_jacket gloves product_collection]
        properties = sub['properties']
        properties.map do |property|
            property_name = property['name'].to_s.downcase.underscore
    
            if PROPERTIES.include?(property_name)
              property_value = property['value']
              value = upcased_properties.include?(property_name) ? property_value.to_s.upcase : property_value
              selected_properties[property_name.to_sym] = value          
            end
          end
          
          selected_properties.merge!(subscription_id: sub['id'], created_at: sub['created_at'], updated_at: sub['updated_at'])

          #Here check for all possible properties and insert nil values for them if they don't exist
          all_properties.each do |myall|
            if selected_properties.include?(myall.to_sym) == false
                selected_properties[myall.to_sym] = nil

            end
          end

          puts selected_properties
          return selected_properties

    end

    def self.test_props
      test_stuff = [{"name"=>"leggings", "value"=>"L"}, {"name"=>"sports-bra", "value"=>"M"}, {"name"=>"tops", "value"=>"M"}, {"name"=>"sports-jacket", "value"=>"M"}, {"name"=>"gloves", "value"=>"L"}]
      my_value = test_stuff.select {|x| x['name'] == "product_collection"}
      puts my_value.inspect

    end

    def self.process_sub(sub)
        #my_product_collection = sub['properties']&.select { |x| x['name'] == "product_collection"}.first['value'] 
        puts "sub['properties'] = #{sub['properties'].inspect}"
        my_value = sub['properties'].select {|x| x['name'] == "product_collection"}
        puts "::::::::::::::::::"
        puts my_value.inspect
        puts "::::::::::::::::::"
        my_product_collection  = nil
        if sub['properties']&.select { |x| x['name'] == "product_collection"} != nil && sub['properties']&.select { |x| x['name'] == "product_collection"} != []
          my_product_collection = sub['properties'].select { |x| x['name'] == "product_collection"}.first['value']
        end
        #puts "my_product_collection = #{my_product_collection.inspect}"
        local_sub = {
            subscription_id: sub['id'],
            status: sub['status'],
            address_id: sub['address_id'],
            charge_interval_frequency: sub['charge_interval_frequency'],
            created_at: sub['created_at'],
            updated_at: sub['updated_at'],
            customer_id: sub['customer_id'],
            email: sub['email'],
            expire_after_specific_number_of_charges: sub['expire_after_specific_number_of_charges'],
            has_queued_charges: sub['has_queued_charges'],
            is_prepaid: sub['is_prepaid'],
            is_skippable: sub['is_skippable'],
            is_swappable: sub['is_swappable'],
            max_retries_reached: sub['max_retries_reached'],
            next_charge_scheduled_at: sub['next_charge_scheduled_at'],
            order_day_of_month: sub['order_day_of_month'],
            order_day_of_week: sub['order_day_of_week'],
            order_interval_frequency: sub['order_interval_frequency'],
            order_interval_unit: sub['order_interval_unit'],
            price: sub['price'],
            product_title: sub['product_title'],
            properties: sub['properties'],
            quantity: sub['quantity'],
            recharge_product_id: sub['recharge_product_id'],
            shopify_product_id: sub['shopify_product_id'],
            shopify_variant_id: sub['shopify_variant_id'],
            sku: sub['sku'],
            sku_override: sub['sku_override'],
            variant_title: sub['variant_title'],
            product_collection: my_product_collection        
        }
        return local_sub
    end   
    

    


end