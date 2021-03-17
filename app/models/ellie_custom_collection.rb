# frozen_string_literal: true

class EllieCustomCollection < ApplicationRecord
  has_many :ellie_collects, primary_key: :collection_id, foreign_key: :collection_id
  has_many :ellie_products, through: :ellie_collects
end
