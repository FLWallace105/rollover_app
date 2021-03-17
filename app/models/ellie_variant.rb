# frozen_string_literal: true

# Handles variants from shopify API
class EllieVariant < ApplicationRecord
  belongs_to :ellie_product, primary_key: :product_id, foreign_key: :product_id
end
