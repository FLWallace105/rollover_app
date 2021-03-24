# frozen_string_literal: true

class HttpartyService
    DEFAULT_TIMEOUT = 80
  
    def self.get(url, headers = {}, query = {})
      headers = build_headers(headers)
      HTTParty.get(URI(url), headers: headers, query: query, timeout: DEFAULT_TIMEOUT)
    end
  
    def self.post(url, headers, body)
      headers = build_headers(headers)
      HTTParty.post(URI(url), headers: headers, body: body.to_json, timeout: DEFAULT_TIMEOUT)
    end
  
    def self.put(url, headers, body)
      headers = build_headers(headers)
      HTTParty.put(URI(url), headers: headers, body: body.to_json, timeout: DEFAULT_TIMEOUT)
    end
  
    def self.parse_response(response)
      #puts response.inspect
      recharge_header = response.response["x-recharge-limit"]
      #puts recharge_header.inspect
      #exit
      determine_limits(recharge_header, 0.65)
      JSON.parse(response.body)
    end
  
    private
  
    def self.build_headers(new_headers)
      default_headers = {
        'Content-Type' => 'application/json',
        'X-Recharge-Access-Token' => Rails.application.credentials.recharge[:recharge_access_token]
      }
      #puts "default_headers = #{default_headers.inspect}"
      default_headers.merge!(new_headers) if new_headers
  
      default_headers
    end

    #recharge_header = my_update_sub.response["x-recharge-limit"]
    #determine_limits(recharge_header, 0.65)

    def self.determine_limits(recharge_header, limit)
      puts "recharge_header = #{recharge_header}"
      my_numbers = recharge_header.split("/")
      my_numerator = my_numbers[0].to_f
      my_denominator = my_numbers[1].to_f
      my_limits = (my_numerator/ my_denominator)
      puts "We are using #{my_limits} % of our API calls"
      if my_limits > limit
          puts "Sleeping 15 seconds"
          sleep 15
      else
          puts "not sleeping at all"
      end
  
    end

  end
  