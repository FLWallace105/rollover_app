# frozen_string_literal: true

# Handles metafields from shopify API
class EllieMetafield < ApplicationRecord
  belongs_to :ellie_product, primary_key: :product_id, foreign_key: :product_id
end
