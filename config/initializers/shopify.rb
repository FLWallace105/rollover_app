ShopifyAPI::Base.site = "https://#{ENV['shopify_api_key']}:#{ENV['shopify_password']}@#{ENV['shopify_shop_name']}.myshopify.com/admin"
ShopifyAPI::Base.api_version = '2020-04'
