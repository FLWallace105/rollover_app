class SizeAdder

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


    def self.create_update_date_json(temp_address_id, temp_subscription_id)
        my_integer = rand(5..30)
        my_str = ""
        if my_integer < 10
            my_str = "0#{my_integer}"
        else
            my_str = "#{my_integer}"
        end
        my_date = "2022-01-#{my_str}"

        temp_json = {
            "body": {
            "address_id": temp_address_id,
            "subscriptions": [
                {
                  "id": temp_subscription_id,
                  "next_charge_scheduled_at": "2022-03-31"
                }
              ]
            }
        }
    return temp_json


    end



end