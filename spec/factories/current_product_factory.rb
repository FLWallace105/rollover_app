FactoryBot.define do
  factory :current_product do
    prod_id_key { nil }
    prod_id_value { nil }
    next_month_prod_id { nil }
    prepaid { false }
  end
end
