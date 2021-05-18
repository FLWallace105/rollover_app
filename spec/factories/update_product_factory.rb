FactoryBot.define do
  factory :update_product do
    sku { '101010' }
    product_title { "Test" }
    shopify_product_id { nil }
    shopify_variant_id { nil }
    product_collection { "Test collection" }
  end
end
