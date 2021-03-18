class SelectionSet < ApplicationRecord
    enum selection_set_type: [:monthly_subscription, :prepaid_subscription, :prepaid_order]


    

    def generate_sql_command
       next_month_product_collection_name = "August 18 Collections"#Date.today.next_month.strftime("%B %Y") + " Collections"


       #use above to get custom_collection.
       custom_collection = EllieCustomCollection.where(title: next_month_product_collection_name).last #one custom collection only

       #then get the collects
       collects = custom_collection.ellie_collects

       #then get the products that belong to those above collects.
       products = collects.map{|collect| collect.ellie_product }

       #Then get the product_collection metafield from the products above and stuff into array
       product_collections = products.map{|product| product.ellie_metafield&.product_collection }.compact

       if !self.allow_ellie_picks_in_selection_set
        #then do not exclude ellie picks, remove from array above
        product_collections = product_collections.reject{|product_collection_name| product_collection_name.include?('ellie picks') }
      end

      # product_array_to_exclude = product_collections

      if ['monthly_subscription', 'prepaid_subscription'].include?(self.selection_set_type)

        my_sql_frag = " and ( "
        product_collections.each do |myvalue|
          my_sql_frag << "sub_collection_sizes.product_collection not ilike \'#{myvalue}\' and "
        end
        my_sql_frag << + ")"

        my_sql_frag << " and ( sub_collection_sizes.leggings = '#{self.leggings}' and sub_collection_sizes.tops = '#{self.tops}' and sub_collection_sizes.sports_bra = '#{self.sports_bra}' and sub_collection_sizes.sports_jacket = '#{self.sports_jacket}'"

        my_sql_frag = self.use_gloves_in_size_breaks ? my_sql_frag + " and sub_collection_sizes.gloves = '#{self.gloves}' )" : " )"
      else

      end

       #Need to do same with orders obviously.

       set_type_selected = ""

       case self.selection_set_type.to_sym
       when :monthly_subscription
        set_type_selected = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at >= \'#{self.start_date}\' and subscriptions.next_charge_scheduled_at <= \'#{self.end_date}\' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and subscriptions.is_prepaid = \'f\' and #{my_sql_frag}"
       when :prepaid_subscription
        set_type_selected = "insert into subscriptions_updated (subscription_id, customer_id, updated_at, created_at,  next_charge_scheduled_at, product_title, status, sku, shopify_product_id, shopify_variant_id, raw_line_items) select subscriptions.subscription_id, subscriptions.customer_id, subscriptions.updated_at, subscriptions.created_at, subscriptions.next_charge_scheduled_at, subscriptions.product_title, subscriptions.status, subscriptions.sku, subscriptions.shopify_product_id, subscriptions.shopify_variant_id, subscriptions.raw_line_item_properties from subscriptions, sub_collection_sizes where subscriptions.status = 'ACTIVE' and subscriptions.next_charge_scheduled_at > '2020-12-31' and subscriptions.next_charge_scheduled_at < '2021-02-01' and sub_collection_sizes.subscription_id = subscriptions.subscription_id and subscriptions.is_prepaid = \'t\' and (  sub_collection_sizes.product_collection not ilike 'ellie%pick%' and sub_collection_sizes.product_collection not ilike 'on%run%' and sub_collection_sizes.product_collection not ilike 'coral%kiss%' and sub_collection_sizes.product_collection not ilike 'funfetti%' and sub_collection_sizes.product_collection not ilike 'island%sun%' and sub_collection_sizes.product_collection not ilike 'island%splash%' and sub_collection_sizes.product_collection not ilike 'force%nature%' and sub_collection_sizes.product_collection not ilike 'daily%mantra%' and sub_collection_sizes.product_collection not ilike 'grayscale%')"

       when :prepaid_order
        set_type_selected = "insert into update_prepaid (order_id, transaction_id, charge_status, payment_processor, address_is_active, status, order_type, charge_id, address_id, shopify_id, shopify_order_id, shopify_cart_token, shipping_date, scheduled_at, shipped_date, processed_at, customer_id, first_name, last_name, is_prepaid, created_at, updated_at, email, line_items, total_price, shipping_address, billing_address, synced_at) select orders.order_id, orders.transaction_id, orders.charge_status, orders.payment_processor, orders.address_is_active, orders.status, orders.order_type, orders.charge_id, orders.address_id, orders.shopify_id, orders.shopify_order_id, orders.shopify_cart_token, orders.shipping_date, orders.scheduled_at, orders.shipped_date, orders.processed_at, orders.customer_id, orders.first_name, orders.last_name, orders.is_prepaid, orders.created_at, orders.updated_at, orders.email, orders.line_items, orders.total_price, orders.shipping_address, orders.billing_address, orders.synced_at from orders, order_collection_sizes where order_collection_sizes.order_id = orders.order_id and  orders.is_prepaid = '1'  and orders.scheduled_at > \'2021-03-05\' and orders.scheduled_at < \'2021-04-01\' and orders.status = \'QUEUED\' and (order_collection_sizes.product_collection not ilike 'head%cloud%'  and order_collection_sizes.product_collection not ilike 'ellie%pick%' ) "
       else
        #should fail, something went wrong
        set_type_selected = ""
       end


       #SubscriptionsUpdated.delete_all
       #Now reset index
       #ActiveRecord::Base.connection.reset_pk_sequence!('subscriptions_updated')
       #ActiveRecord::Base.connection.execute(mar2021_monthly_straggler)



    end

end
