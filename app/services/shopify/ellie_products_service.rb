# frozen_string_literal: true

module Shopify
  # Class to fetch and store products from Shopify API
  class EllieProductsService < EllieService
    DEFAULT_ENTRIES = 20
    DEFAULT_METAFIELD_NAMESPACE = 'ellie_order_info'
    MINIMUM_COST_ALLOWED = 322
    GRAPHQL_SLEEP_TIME = Rails.application.credentials[:graphql_sleep_time].to_i

    class << self
      def fetch(extra_options: nil)
        default_options = {
          products: "first: #{DEFAULT_ENTRIES}, query: \"\"",
          metafields: "first: #{EllieMetafieldsService::DEFAULT_ENTRIES}, namespace: \"#{DEFAULT_METAFIELD_NAMESPACE}\"",
          variants: "first: #{EllieVariantsService::DEFAULT_ENTRIES}"
        }

        default_options.merge!(extra_options) if extra_options
        query = graphql_query(options: default_options)
        results = client.query(query)

        unless results.errors.empty?
          raise StandardError, 'The requests were throttled or could not be made'
        end

        available_cost = results.extensions['cost']['throttleStatus']['currentlyAvailable']
        puts "available cost: " + available_cost.to_s

        sleep GRAPHQL_SLEEP_TIME if available_cost < MINIMUM_COST_ALLOWED

        results.data.products.edges
      end

      def build_instances(products)
        products.each_with_object([]) do |product, product_instances|
          # next if product.node.metafields.edges.empty?

          product_attrs = build_attributes(product.node)
          product_instances << product_attrs
        end
      end

      def store(products)
        EllieProduct.import(products, batch_size: 50, all_or_none: true)
        puts "Total products stored: #{products.count}"
      end

      private

      def graphql_query(options:)
        client.parse <<~GRAPHQL
          {
            products(#{options[:products]}) {
              edges {
                cursor
                node {
                  id
                  title
                  productType
                  handle
                  templateSuffix
                  bodyHtml
                  createdAt
                  updatedAt
                  vendor
                  tags
                  defaultCursor
                  legacyResourceId
                  options {
                    id
                    name
                    position
                    values
                  }
                  metafields(#{options[:metafields]}) {
                    edges {
                      node {
                        id
                        legacyResourceId
                        value
                      }
                    }
                  }
                  variants(#{options[:variants]}) {
                    edges {
                      node {
                        sku
                        title
                        id
                        inventoryQuantity
                        legacyResourceId
                      }
                    }
                  }
                }
              }
              pageInfo {
                hasNextPage
                hasPreviousPage
              }
            }
          }
        GRAPHQL
      end

      def client
        ShopifyAPI::GraphQL.client
      end

      def build_attributes(product)
        {
          product_id: product.legacy_resource_id,
          title: product.title,
          product_type: product.product_type,
          handle: product.handle,
          template_suffix: product.template_suffix,
          body_html: product.body_html,
          tags: product.tags.join(', '),
          vendor: product.vendor,
          options: product.options
        }
      end
    end
  end
end
