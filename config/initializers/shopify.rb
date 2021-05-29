ShopifyAPI::Base.site = "https://#{Rails.application.credentials[:shopify_api_key]}:#{Rails.application.credentials[:shopify_password]}@#{Rails.application.credentials[:shopify_shop_name]}.myshopify.com/admin"
ShopifyAPI::Base.api_version = '2020-04'
