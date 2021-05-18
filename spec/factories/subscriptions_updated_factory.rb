FactoryBot.define do
  factory :subscriptions_updated do
    subscription_id { nil }
    customer_id { nil }
    next_charge_scheduled_at { Date.today + 1.month }
    product_title { 'Test' }
    status { 'active' }
    sku { '0001' }
    shopify_product_id { nil }
    shopify_variant_id { nil }
    product_collection { 'Test Collection' }
    is_prepaid { false }
    properties { {} }
    pushed_to_batch_request { false }
    is_updated_on_recharge { false }
    date_updated_on_recharge { Date.today }
  end
end
