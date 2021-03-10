

module RechargeSubCache
    BASE_URI = 'https://api.rechargeapps.com'

    def self.get_all_subs
        puts "Hi in the self module"
        page_size = 250
        url = "#{BASE_URI}/subscriptions/count"
        query = { status: 'active' }
        response = HttpartyService.get(url, {}, query)
        subs_response = HttpartyService.parse_response(response)
        puts subs_response.inspect

    end


end