class PullShopifyResources
  def call
      # puts "Starting all shopify resources download"
      # shop_url = "https://#{@api_key}:#{@password}@#{@shopname}.myshopify.com/admin"
      # puts shop_url

      # ShopifyAPI::Base.site = shop_url
      # ShopifyAPI::Base.api_version = '2020-04'
      ShopifyAPI::Base.timeout = 180

      product_count = ShopifyAPI::Product.count()

      puts "We have #{product_count} products for Ellie"

      cursor_num_products = 0
      num_variants = 0

      ShopifyProduct.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('shopify_products')
      ShopifyVariant.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('shopify_variants')
      ShopifyCollect.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('shopify_collects')
      ShopifyCustomCollection.delete_all
      ActiveRecord::Base.connection.reset_pk_sequence!('shopify_custom_collections')

      products = ShopifyAPI::Product.find(:all)

      #First page
      products.each do |myp|
        puts "-----"
        puts "product_id: #{myp.id}"

        create_product(myp)
        puts "--------"
        #variants here
        myvariants = myp.variants

        myvariants.each do |myvar|
          puts "++++++++++++++"
          puts "variant_id: #{myvar.id}"
          puts "++++++++++++++"

          create_variant(myvar)
          num_variants += 1
        end

        shopify_api_throttle
        cursor_num_products += 1
      end

      while products.next_page?
        products = products.fetch_next_page

        products.each do |myp|
          puts "-----"
          create_product(myp)
          puts "product_id: #{myp.id}"

          puts "-----"

          #variants here
          myvariants = myp.variants
          myvariants.each do |myvar|
            puts "++++++++++++++"
            puts "variant_id: #{myvar.id}"
            puts "++++++++++++++"

            create_variant(myvar)
            num_variants += 1
          end

          cursor_num_products += 1
        end
        #puts "Sleeping 3 secs"
        #sleep 3
        shopify_api_throttle
      end

      puts "We have #{product_count} products for Ellie and have processed #{cursor_num_products} products"
      puts "We have #{num_variants} variants for parent products"


      #collects

      num_collects = 0
      collect_count = ShopifyAPI::Collect.count()
      puts "We have #{collect_count} collects"

      mycollects = ShopifyAPI::Collect.find(:all)

      mycollects.each do |mycollect|
        #puts mycollect.inspect
        puts "*************"
        puts "collect_id: #{mycollect.id}"
        puts "*************"

        create_collect(mycollect)
        num_collects += 1
        shopify_api_throttle
      end

      while mycollects.next_page?
        mycollects = mycollects.fetch_next_page
        mycollects.each do |mycollect|
          #puts mycollect.inspect
          puts "*************"
          puts "collect_id: #{mycollect.id}"
          puts "*************"

          create_collect(mycollect)
          num_collects += 1
        end
        #puts "Sleeping 3 secs"
        #sleep 3
        shopify_api_throttle
      end

      puts "We have #{collect_count} collects and have processed #{num_collects} collects"

      collection_count = ShopifyAPI::CustomCollection.count()
      puts "We have #{collection_count} collections for Ellie"

      num_custom_collections = 0

      mycollections = ShopifyAPI::CustomCollection.find(:all)
      mycollections.each do |myc|
        #puts myc.inspect
        puts "_________________"
        puts "custom_collection_id: #{myc.id}"
        puts "_________________"

        create_custom_collection(myc)
        num_custom_collections += 1
        shopify_api_throttle
      end

      while mycollections.next_page?
        mycollections = mycollections.fetch_next_page
        mycollections.each do |myc|
          #puts myc.inspect
          puts "_________________"
          puts "custom_collection_id: #{myc.id}"
          puts "_________________"

          create_custom_collection(myc)
          num_custom_collections += 1
        end
        #puts "Sleeping 3 secs"
        #sleep 3
        shopify_api_throttle
      end

      puts "We have #{collection_count} custom collections for Ellie and have processed #{num_custom_collections} custom collections"


      #Count up objects in tables
      num_products = ShopifyProduct.count
      puts "We have #{num_products} products in the db "

      num_variants = ShopifyVariant.count
      puts "We have #{num_variants} variants in the db"

      num_collects = ShopifyCollect.count
      puts "We have #{num_collects} collects in the db"

      num_custom_collections = ShopifyCustomCollection.count
      puts "We have #{num_custom_collections} custom collections in the db"


  end

  private

  def shopify_api_throttle
    return if ShopifyAPI.credit_left > 5

    puts "CREDITS LEFT: #{ShopifyAPI.credit_left}"
    puts "SLEEPING 20"
    sleep 20
  end

  def create_product(product)
    ShopifyProduct.create(
      product_id: product.attributes['id'],
      title: product.attributes['title'],
      product_type: product.attributes['product_type'],
      created_at: product.attributes['created_at'],
      updated_at: product.attributes['updated_at'],
      handle: product.attributes['handle'],
      template_suffix: product.attributes['template_suffix'],
      body_html: product.attributes['body_html'],
      tags: product.attributes['tags'],
      published_scope: product.attributes['published_scope'],
      vendor: product.attributes['vendor'],
      options: product.attributes['options'][0].attributes,
      published_at: product.attributes['published_at']
    )
  end

  def create_variant(variant)
    ShopifyVariant.create(
      variant_id: variant.attributes['id'],
      product_id: variant.prefix_options[:product_id],
      title: variant.attributes['title'],
      price: variant.attributes['price'],
      sku: variant.attributes['sku'],
      position: variant.attributes['position'],
      inventory_policy: variant.attributes['inventory_policy'],
      compare_at_price: variant.attributes['compare_at_price'],
      fulfillment_service: variant.attributes['fulfillment_service'],
      inventory_management: variant.attributes['inventory_management'],
      option1: variant.attributes['option1'],
      option2: variant.attributes['option2'],
      option3: variant.attributes['option3'],
      created_at: variant.attributes['created_at'],
      updated_at: variant.attributes['updated_at'],
      taxable: variant.attributes['taxable'],
      barcode: variant.attributes['barcode'],
      weight_unit: variant.attributes['weight_unit'],
      weight: variant.attributes['weight'],
      inventory_quantity: variant.attributes['inventory_quantity'],
      image_id: variant.attributes['image_id'],
      grams: variant.attributes['grams'],
      inventory_item_id: variant.attributes['inventory_item_id'],
      tax_code: variant.attributes['tax_code'],
      old_inventory_quantity: variant.attributes['old_inventory_quantity'],
      requires_shipping: variant.attributes['requires_shipping']
    )
  end

    def create_variant(variant)
      ShopifyVariant.create(variant_id: variant.attributes['id'], product_id: variant.prefix_options[:product_id], title: variant.attributes['title'], price: variant.attributes['price'], sku: variant.attributes['sku'], position: variant.attributes['position'], inventory_policy: variant.attributes['inventory_policy'], compare_at_price: variant.attributes['compare_at_price'], fulfillment_service: variant.attributes['fulfillment_service'], inventory_management: variant.attributes['inventory_management'], option1: variant.attributes['option1'], option2: variant.attributes['option2'], option3: variant.attributes['option3'], created_at: variant.attributes['created_at'], updated_at: variant.attributes['updated_at'], taxable: variant.attributes['taxable'], barcode: variant.attributes['barcode'], weight_unit: variant.attributes['weight_unit'], weight: variant.attributes['weight'], inventory_quantity: variant.attributes['inventory_quantity'], image_id: variant.attributes['image_id'], grams: variant.attributes['grams'], inventory_item_id: variant.attributes['inventory_item_id'], tax_code: variant.attributes['tax_code'], old_inventory_quantity: variant.attributes['old_inventory_quantity'], requires_shipping: variant.attributes['requires_shipping']  )
    end

    def create_collect(collect)
      ShopifyCollect.create(
        collect_id: collect.attributes['id'],
        collection_id: collect.attributes['collection_id'],
        product_id: collect.attributes['product_id'],
        featured: collect.attributes['featured'],
        created_at: collect.attributes['created_at'],
        updated_at: collect.attributes['updated_at'],
        position: collect.attributes['position'],
        sort_value: collect.attributes['sort_value']
      )
    end

    def create_custom_collection(collection)
       ShopifyCustomCollection.create(collection_id: collection.attributes['id'], handle: collection.attributes['handle'], title: collection.attributes['title'], updated_at: collection.attributes['updated_at'], body_html: collection.attributes['body_html'], published_at: collection.attributes['published_at'], sort_order: collection.attributes['sort_order'], template_suffix: collection.attributes['template_suffix'], published_scope: collection.attributes['published_scope'])
    end
end