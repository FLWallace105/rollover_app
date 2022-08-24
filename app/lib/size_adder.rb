class SizeAdder

    VALID_PROPS = ["leggings", "tops", "sports-jacket", "sports-bra", "gloves", "product_collection", "real_email", "unique_identifier"]

    def self.add_size_sub_properties(properties)

        leggings = properties.select{|x| x['name'] == 'leggings'}
        tops = properties.select{|x| x['name'] == 'tops'}
        sports_bra = properties.select{|x| x['name'] == 'sports-bra'}
        sports_jacket = properties.select{|x| x['name'] == 'sports-jacket'}
        gloves = properties.select{|x| x['name'] == 'gloves'}

        #puts "sports_bra = #{sports_bra}"
        #puts "tops = #{tops}"
        #puts "***********"
        #Assuming we always have leggings
        if sports_jacket == [] && tops != []
            properties << { "name" => "sports-jacket", "value" => tops.first['value'].upcase }
        end

        if sports_bra == [] && tops != []
            #puts "FIXING missing sports-bra"
            properties << { "name" => "sports-bra", "value" => tops.first['value'].upcase }
        end

        if tops == [] && sports_bra != []
            properties << { "name" => "tops", "value" => sports_bra.first['value'].upcase }
        end

        if gloves == [] and leggings != []
            leggings_size = leggings.first['value'].upcase
            case leggings_size
            when 'XS', 'S'
                properties << { "name" => "gloves", "value" => "S" }  
            when 'M'
                properties << { "name" => "gloves", "value" => "M" } 
            when 'L', 'XL'
                properties << { "name" => "gloves", "value" => "L" }

            else
                properties << { "name" => "gloves", "value" => "M" }
            end
        end

        properties.delete_if {|x| !VALID_PROPS.include?(x['name']) }
        
        return properties




    end

    def self.create_size_json(temp_address_id, temp_subscription_id, temp_properties)
        temp_json = {
            "body": {
            "address_id": temp_address_id,
            "subscriptions": [
                {
                      "id": temp_subscription_id,
                      "properties": temp_properties
                    }
                  ]
                }
            }


    end


    def self.create_update_json(temp_address_id, temp_subscription_id, sku, product_title, shopify_product_id, shopify_variant_id,temp_properties)

        temp_json = {
                "body": {
                "address_id": temp_address_id,
                "subscriptions": [
                    {
                      "id": temp_subscription_id,
                      "sku": sku,
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



end