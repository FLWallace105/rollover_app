module BulkUpdateSubs
    BASE_URI = 'https://api.rechargeapps.com'
    PROPERTIES = %w[leggings tops sports_bra sports_jacket gloves product_collection].freeze

    def self.setup_update_subs
        puts "starting bulk updating"
        my_sql  = "insert into subscriptions_updated (subscription_id, customer_id, address_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, properties, is_prepaid) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.address_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.properties, subscriptions.is_prepaid from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at > '2021-03-31' and subscriptions.next_charge_scheduled_at < '2021-05-01' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and subscriptions.is_prepaid = \'f\' "

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
        
        UpdateProduct.create(product_title: 'Boss Babe - 2 Items', sku: '764204806164', shopify_product_id: 4171973099659, shopify_variant_id: 30330213269643, product_collection: 'Boss Babe - 2 Items', created_at: now, updated_at: now)
        UpdateProduct.create(product_title: 'Boss Babe - 3 Items', sku: '764204806171', shopify_product_id: 4171972345995, shopify_variant_id: 30330211532939, product_collection: 'Boss Babe - 3 Items', created_at: now, updated_at: now )
        UpdateProduct.create(product_title: 'Boss Babe - 5 Items', sku: '764204816828', shopify_product_id: 4171972640907, shopify_variant_id: 30330211926155, product_collection:'Boss Babe - 5 Items', created_at: now, updated_at: now )


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



    end

end