# frozen_string_literal: true

# Handles products from shopify API
class EllieProduct < ApplicationRecord
  has_one :ellie_metafield, primary_key: :product_id, foreign_key: :product_id
  has_many :ellie_variants, primary_key: :product_id, foreign_key: :product_id
  has_many :ellie_collects, primary_key: :product_id, foreign_key: :product_id

  scope :order_by_title, -> { order(title: :asc) }
  scope :with_filters, -> {
    select(:id, :title, 'ellie_metafields.product_collection')
      .joins(:ellie_metafield, :ellie_variants)
      .where.not("ellie_products.title ILIKE '%one%time%'")
      .where.not("ellie_products.title ILIKE '%auto%'")
      .where.not("ellie_products.title ILIKE '%(%)%'")
      .where.not("ellie_products.title ILIKE '3%month%'")
      .where.not("ellie_products.title ILIKE '%2018%'")
      .where.not("ellie_products.title ILIKE '%2019%'")
      .where.not("ellie_products.title ILIKE '%2020%'")
      .where.not("ellie_products.title ILIKE '%activewear%'")
  }

  delegate :product_collection, to: :ellie_metafield, prefix: true, allow_nil: true

  def self.filter(search_param)
    with_filters
      .where(
        'ellie_products.title ILIKE :search_param OR ellie_metafields.product_collection ILIKE :search_param',
        search_param: "%#{search_param}%"
      )
      .order_by_title
  end
end
