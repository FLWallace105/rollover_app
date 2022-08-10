class MixMatchScrubber

    VALID_PROPS = ["leggings", "tops", "sports-jacket", "sports-bra", "gloves", "product_collection", "real_email", "unique_identifier"]

    def self.scrub_mix_match(temp_address_id, temp_subscription_id, sku, product_title, shopify_product_id, shopify_variant_id,temp_properties)

        temp_properties = scrub_off_mix_match(temp_properties)

        temp_json = {
                "body": {
                "address_id": temp_address_id,
                "subscriptions": [
                    {
                      "id": temp_subscription_id,
                      "sku": sku,
                      "status": "ACTIVE",
                      "product_title": product_title,
                      "shopify_product_id": shopify_product_id,
                       "shopify_variant_id": shopify_variant_id,
                      "properties": temp_properties
                    }
                  ]
                }
            }
        return temp_json


    end

    def self.scrub_off_mix_match(properties)
        properties.delete_if {|x| !VALID_PROPS.include?(x['name']) }

    
        return properties
    end

   


    

end