module BulkUpdateSubs
    BASE_URI = 'https://api.rechargeapps.com'
    PROPERTIES = %w[leggings tops sports_bra sports_jacket gloves product_collection].freeze

    def self.setup_update_subs
        puts "starting bulk updating"
        my_sql  = "insert into subscriptions_updated (subscription_id, customer_id, address_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, properties, is_prepaid) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.address_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.properties, subscriptions.is_prepaid from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE'  and sub_collection_sizes.subscription_id = subscriptions.subscription_id and subscriptions.is_prepaid = \'f\' "

        SubscriptionsUpdated.delete_all
        #Now reset index
        ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
        ActiveRecord::Base.connection.execute(my_sql)

        puts "Done with set up of subscriptions"
        UpdateProduct.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('update_products')
        now = DateTime.now.strftime("%Y-%m-%e %H:%M:%S")
        puts now

        #Boss Babe exists in Recharge, use that for set up
        
        UpdateProduct.create(product_title: 'Canyon Sunset - 2 Items', sku: '764204816835', shopify_product_id: 4171973263499, shopify_variant_id: 30330213761163, product_collection: 'Canyon Sunset - 2 Items', created_at: now, updated_at: now)
        UpdateProduct.create(product_title: 'Canyon Sunset - 3 Items', sku: '764204816842', shopify_product_id: 4643650699403, shopify_variant_id: 32786274615435, product_collection: 'Canyon Sunset - 3 Items', created_at: now, updated_at: now )
        UpdateProduct.create(product_title: 'Canyon Sunset - 5 Items', sku: '764204843701', shopify_product_id: 4171973361803, shopify_variant_id: 30330213892235, product_collection:'Canyon Sunset - 5 Items', created_at: now, updated_at: now )


        puts "Done with set up of update_products table"

        CurrentProduct.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('current_products')

        my_config_sql = "select count(id), product_title, shopify_product_id from subscriptions_updated group by product_title, shopify_product_id order by product_title asc"

        ActiveRecord::Base.connection.execute(my_config_sql).each do |row|
            puts row.inspect
            next_month_prod_id = 99999
            my_title = row['product_title']
            my_prod_id = row['shopify_product_id']

            case my_title
            when /\s2\sitem/i
                next_month_prod_id = 4171973099659
            when /\s3\sitem/i
                next_month_prod_id = 4171972345995
            when /\s5\sitem/i
                next_month_prod_id = 4171972640907
            when "3 MONTHS"
                next_month_prod_id = 4171972640907
            else
                next_month_prod_id = 4171972640907
            end
            CurrentProduct.create(prod_id_key: my_title, prod_id_value: my_prod_id, next_month_prod_id: next_month_prod_id, prepaid: false, created_at: now, updated_at: now )

      end
      my_current_products = CurrentProduct.all
      my_current_products.each do |myp|
        puts myp.inspect
      end

    num_batches_needed = determine_batches_needed
    puts "We need #{num_batches_needed} batches"

    end

    def self.determine_batches_needed
       
        num_subs = SubscriptionsUpdated.count
        batch_size = 10000 #total number of tasks i.e. subs one batch can have
        num_batches = (num_subs / batch_size.to_f).ceil
        #puts "num_batches needed = #{num_batches}"
        return num_batches


    end

    def self.create_batch_task
        puts "Starting batch task creation"
        body = {"batch_type": "bulk_subscriptions_update"}
        url = "#{BASE_URI}/async_batches"
        response = HttpartyService.post(url, {}, body)
        puts response.inspect
        batch_id = response.parsed_response['async_batch']['id']
        puts "batch_id = #{batch_id}"
        #probably need to save to database here, leaving for now
        puts "Done!"

    end

    def self.bulk_update_subs
        #WARNING WARNING WARNING WARNING
        #Code below is ONLY for non-prepaid subscriptions. Will need to check on prepaid value in 
        #SubscriptionsUpdated.is_prepaid value


        #POST /async_batches
        body = {"batch_type": "bulk_subscriptions_update"}
        url = "#{BASE_URI}/async_batches"
        #response = HttpartyService.post(url, {}, body)
        #puts response.inspect
        #batch_id = response.parsed_response['async_batch']['id']
        #probably need to save to database here, leaving for now
        #"id"=>16085

        #POST /async_batches/batch_id/tasks

        #my_tasks = { "tasks": [] }
        temp_tasks = Array.new
        mycount = 1

        proceed_with_batch_info = false
        temp_subs = SubscriptionsUpdated.where("pushed_to_batch_request = ?", false)
        temp_subs.each do |temps|
            #Have at least one to add to batch so ...
            proceed_with_batch_info = true
            puts temps.inspect
            my_next_product_id = CurrentProduct.find_by_prod_id_value(temps.shopify_product_id)
            puts "-----------"
            puts my_next_product_id.inspect
            puts "-------------"
            my_update_info = UpdateProduct.where("shopify_product_id = ?", my_next_product_id.next_month_prod_id ).first
            puts "********************"
            puts my_update_info.inspect
            puts "*******************"
            #gather info
            temp_subscription_id = temps.subscription_id
            temp_address_id = temps.address_id
            product_title = my_update_info.product_title
            sku = my_update_info.sku
            shopify_product_id = my_update_info.shopify_product_id
            shopify_variant_id = my_update_info.shopify_variant_id
            product_collection = my_update_info.product_collection
            temp_properties = temps.properties
            temp_properties.map do |x|
                if x['name'] == "product_collection"
                    x['value'] = product_collection
                end

            end

            send_to_recharge = { "sku" => sku, "product_title" => product_title, "shopify_product_id" => shopify_product_id, "shopify_variant_id" => shopify_variant_id, "properties" => temp_properties }

            puts "----------------------------"
            puts "send_to_recharge = #{send_to_recharge.inspect}"
            puts "-----------------------------"
            temp_json = {
                "body": {
                "address_id": temp_address_id,
                "subscriptions": [
                    {
                      "id": temp_subscription_id,
                      "sku": sku,
                      "product_title": product_title,
                      "shopify_product_id": shopify_product_id,
                      "shopify_variant_id": shopify_variant_id,
                      "properties": temp_properties
                    }
                  ]
                }
            }
            temp_tasks.push(temp_json)
            mycount += 1
            temps.pushed_to_batch_request = true
            temps.save!
            break if mycount > 1000

        end

        my_tasks = { "tasks": temp_tasks } 
        puts "JSON for RECHARGE: \n\n\n"
        puts my_tasks.inspect
        puts "\n\n\n\n"
        puts "*****************"
        puts "*****************"
        puts "*****************"

        if proceed_with_batch_info == true
            body = my_tasks
            url = "#{BASE_URI}/async_batches/16086/tasks"
            response = HttpartyService.post(url, {}, body)
            puts response.inspect
        else
            puts "No more batch tasks to add for this batch"
        end

        puts "Done with this module"
        
        #"id"=>16085

        



        

    end

    def self.send_task_process
        #POST /async_batches/:batch_id/process
        #request.body = "{}"
        body = {}
        url = "#{BASE_URI}/async_batches/16086/process"
        response = HttpartyService.post(url, {}, body)
        puts response.inspect


    end

    def self.get_task_info
        #GET /async_batches/<batch_id>
        url = "#{BASE_URI}/async_batches/16086"
        query = {}
        response = HttpartyService.get(url, {}, query)
        puts response.inspect

        num_tasks_total = response.parsed_response['async_batch']['total_task_count'].to_i
        puts "num_tasks_total = #{num_tasks_total}"
        page_size = 250
        num_pages = (num_tasks_total / page_size.to_f).ceil
        new_query = {limit: page_size }

        #GET https://api.rechargeapps.com/async_batches/:batch_id/tasks
        my_counter = 1

        1.upto(num_pages) do |page|

            new_url = "#{BASE_URI}/async_batches/16086/tasks"
            new_query.merge!(page: page)
            task_response = HttpartyService.get(new_url, {}, new_query)
            puts task_response.inspect
            my_info = task_response.parsed_response['async_batch_tasks']

            
            my_info.each do |myi|
                puts "---------"
                puts myi['result']['output']['subscriptions']
                status_of_request = myi['result']['status_code'].to_i
                if status_of_request != 200
                    puts "PROBLEM -->"
                    puts myi['result']
                    #exit
                else
                    #log to database.
                end
                puts "Item #{my_counter}"
                puts "---------"
                my_counter += 1

                end
            puts "Done with page #{page}"
        end
        puts "All done with task pages"

    end

end