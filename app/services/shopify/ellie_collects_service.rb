# frozen_string_literal: true

module Shopify
  # Class to fetch and store collects from Shopify API
  class EllieCollectsService
    class << self
      def fetch(extra_options: nil)
        collection_size = ShopifyAPI::Collect.count
        puts "We have #{collection_size} collections for Ellie"

        EllieCollect.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('ellie_collects')

        shopify_collects = ShopifyAPI::Collect.find(:all, params: { limit: 250 })
        collects = []
        collects << process_collects(shopify_collects)

        while shopify_collects.next_page?
          shopify_collects = shopify_collects.fetch_next_page
          collects << process_collects(shopify_collects)
          wait_for_shopify_credits
        end

        store(collects.flatten)
      end

      private

      def wait_for_shopify_credits
        if ShopifyAPI::credit_left < 4
          puts "sleeping for 10 seconds to obtain credits..."
          sleep(10)
        else
          puts "credit limit left #{ShopifyAPI::credit_left}"
        end
      end

      def process_collects(collects)
        my_collects = []
        collects.each do |collect|
          my_collects << build_attributes(collect.attributes)
        end
        my_collects
      end

      def build_attributes(collect)
        {
          collect_id: collect['id'],
          collection_id: collect['collection_id'],
          product_id: collect['product_id'],
          featured: collect['featured'],
          created_at: collect['created_at'],
          updated_at: collect['updated_at'],
          position: collect['position'],
          sort_value: collect['sort_value']
        }
      end

      def store(collects)
        EllieCollect.import(collects, batch_size: 50, all_or_none: true)
        puts "Total collects stored: #{collects.count}"
      end
    end
  end
end
