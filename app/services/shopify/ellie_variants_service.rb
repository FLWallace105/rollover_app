# frozen_string_literal: true

module Shopify
  # Class to fetch and store variants from Shopify API
  class EllieVariantsService
    DEFAULT_ENTRIES = 5

    class << self
      def build_instances(products)
        products.each_with_object([]) do |product, variant_instances|
          product_node = product.node
          shopify_product_id = product_node.legacy_resource_id
          variant_entries = product_node.variants.edges
          next if variant_entries.empty?

          variant_entries.each do |entry|
            variant_attrs = build_attributes(entry.node, shopify_product_id)
            variant_instances << variant_attrs
          end
        end
      end

      def store(variants)
        EllieVariant.import(variants, batch_size: 50, all_or_none: true)
        puts "Total variants stored: #{variants.count}"
      end

      private

      def build_attributes(variant, shopify_product_id)
        {
          variant_id: variant.legacy_resource_id,
          sku: variant.sku,
          title: variant.title,
          inventory_quantity: variant.inventory_quantity,
          product_id: shopify_product_id
        }
      end
    end
  end
end
