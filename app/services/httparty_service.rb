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
      JSON.parse(response.body)
    end
  
    private
  
    def self.build_headers(new_headers)
      default_headers = {
        'Content-Type' => 'application/json',
        'X-Recharge-Access-Token' => Rails.application.credentials[:recharge][:api_key]
      }
      default_headers.merge!(new_headers) if new_headers
  
      default_headers
    end
  end
  