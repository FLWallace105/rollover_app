# frozen_string_literal: true

module Shopify
  # Class to fetch products from Shopify API with GraphQL
  class EllieService
    class << self
      def fetch
        products = []
        metafields = []
        variants = []

        delete_existing_records

        product_list = EllieProductsService.fetch
        last_cursor = product_list.last.cursor

        products << EllieProductsService.build_instances(product_list)
        metafields << EllieMetafieldsService.build_instances(product_list)
        variants << EllieVariantsService.build_instances(product_list)

        while last_cursor.present?
          extra_options = { products: "first: #{EllieProductsService::DEFAULT_ENTRIES}, after: \"#{last_cursor}\"" }
          product_list = EllieProductsService.fetch(extra_options: extra_options)
          break if product_list.nil?

          last_cursor = product_list.last&.cursor
          products << EllieProductsService.build_instances(product_list)
          metafields << EllieMetafieldsService.build_instances(product_list)
          variants << EllieVariantsService.build_instances(product_list)
        end

        EllieProductsService.store(products.flatten)
        EllieMetafieldsService.store(metafields.flatten)
        EllieVariantsService.store(variants.flatten)
        nil
      end

      private

      def delete_existing_records
        EllieProduct.delete_all
        EllieMetafield.delete_all
        EllieVariant.delete_all

        base_connection = ActiveRecord::Base.connection
        base_connection.reset_pk_sequence!('ellie_products')
        base_connection.reset_pk_sequence!('ellie_metafields')
        base_connection.reset_pk_sequence!('ellie_variants')
      end
    end
  end
end
