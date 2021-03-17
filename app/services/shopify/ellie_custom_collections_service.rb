# frozen_string_literal: true

module Shopify
  # Class to fetch and store custom_collections from Shopify API
  class EllieCustomCollectionsService
    class << self
      def fetch(extra_options: nil)
        collection_size = ShopifyAPI::CustomCollection.count
        puts "We have #{collection_size} collections for Ellie"

        EllieCustomCollection.delete_all
        ActiveRecord::Base.connection.reset_pk_sequence!('ellie_custom_collections')

        shopify_custom_collections = ShopifyAPI::CustomCollection.find(:all, params: { limit: 250 })
        custom_collections = []
        custom_collections << process_custom_collections(shopify_custom_collections)

        while shopify_custom_collections.next_page?
          shopify_custom_collections = shopify_custom_collections.fetch_next_page
          custom_collections << process_custom_collections(shopify_custom_collections)
          wait_for_shopify_credits
        end

        store(custom_collections.flatten)
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

      def process_custom_collections(custom_collections)
        my_custom_collections = []
        custom_collections.each do |mycoll|
          my_custom_collections << build_attributes(mycoll)
        end
        my_custom_collections
      end

      def build_attributes(custom_collection)
        {
          collection_id: custom_collection.id,
          handle: custom_collection.handle,
          title: custom_collection.title,
          updated_at: custom_collection.updated_at,
          body_html: custom_collection.body_html,
          published_at: custom_collection.published_at,
          sort_order: custom_collection.sort_order,
          template_suffix: custom_collection.template_suffix,
          published_scope: custom_collection.published_scope
        }
      end

      def store(custom_collections)
        EllieCustomCollection.import(custom_collections, batch_size: 50, all_or_none: true)
        puts "Total custom collections stored: #{custom_collections.count}"
      end
    end
  end
end
