class AlternateProductsBuilder
  def self.call
    shop_url = "https://#{Rails.application.credentials[:shopify_api_key]}:#{Rails.application.credentials[:shopify_password]}@#{Rails.application.credentials[:shopify_shop_name]}.myshopify.com/admin"
    puts shop_url

    ShopifyAPI::Base.site = shop_url
    ShopifyAPI::Base.api_version = '2020-04'
    ShopifyAPI::Base.timeout = 180

    this_month_name = Date.today.strftime("%B").downcase
    year = Date.today.strftime("%Y")

    my_collection = "select collection_id from shopify_custom_collections where handle ilike '#{this_month_name}%#{year}%collection%' "

    collection_info = ActiveRecord::Base.connection.execute(my_collection).first
    collection_id = collection_info['collection_id']

    my_products = "select product_id from shopify_collects where collection_id = #{collection_id}"
    product_info = ActiveRecord::Base.connection.execute(my_products).values
    puts product_info.inspect
    product_list = product_info.flatten
    puts product_list.inspect

    alternate_product_attributes = []
    product_list.each do |myprod|
      temp_product = ShopifyProduct.find_by_product_id(myprod)
      if temp_product.title !~ /.\sone\stime/i
        mymeta = ShopifyAPI::Metafield.all(params: {resource: 'products', resource_id: temp_product.product_id, namespace: 'ellie_order_info', fields: 'value'})
        puts mymeta.inspect
        sleep 5
        temp_variant = ShopifyVariant.where("product_id = ?", temp_product.product_id ).first
        puts "#{temp_product.title}, #{temp_product.product_id}, #{temp_variant.variant_id}, #{temp_variant.sku}"
        attributes = {
          product_title: temp_product.title,
          product_id: temp_product.product_id,
          variant_id: temp_variant.variant_id,
          sku: temp_variant.sku
        }
        if mymeta != []
          attributes.merge!(product_collection: mymeta.first.attributes['value'])
        end
        alternate_product_attributes << attributes
      end
    end

    AlternateProduct.import alternate_product_attributes
  end
end
