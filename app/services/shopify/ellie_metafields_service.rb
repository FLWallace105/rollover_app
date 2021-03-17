# frozen_string_literal: true

module Shopify
  # Class to fetch and store metafields from Shopify API
  class EllieMetafieldsService
    DEFAULT_ENTRIES = 5

    class << self
      def build_instances(products)
        products.each_with_object([]) do |product, metafield_instances|
          product_node = product.node
          shopify_product_id = product_node.legacy_resource_id
          metafield_entries = product_node.metafields.edges
          next if metafield_entries.empty?

          metafield_entries.each do |entry|
            metafield_attrs = build_attributes(entry.node, shopify_product_id)
            metafield_instances << metafield_attrs
          end
        end
      end

      def store(metafields)
        EllieMetafield.import(metafields, batch_size: 50, all_or_none: true)
        puts "Total metafields stored: #{metafields.count}"
      end

      private

      def build_attributes(metafield, shopify_product_id)
        {
          metafield_id: metafield.legacy_resource_id,
          product_collection: metafield.value,
          product_id: shopify_product_id
        }
      end
    end
  end
end
