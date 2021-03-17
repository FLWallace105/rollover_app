# frozen_string_literal: true

class EllieCollect < ApplicationRecord
  belongs_to :ellie_product, primary_key: :product_id, foreign_key: :product_id
  belongs_to :ellie_custom_collection, primary_key: :collection_id, foreign_key: :collection_id
end
