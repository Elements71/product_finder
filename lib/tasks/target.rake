namespace :target do
  desc 'find switch'
  task :find_switch => :environment do
    tester
  end

  def tester
    switch_array = ["52052007","52189185"]
    target_api_host = "https://api.target.com/"
    switch_array.each do |switch_id|
      url_path = "available_to_promise/v2/#{switch_id}/search?key=eb2551e4accc14f38cc42d32fbc2b2ea&nearby=40.757285,-73.83417&inventory_type=stores&multichannel_option=none&field_groups=location_summary&requested_quantity=1&radius=100"
      response = RestClient.get "#{target_api_host}#{url_path}"
      json = JSON.parse(response)
      product = json['products'].first
      online_status = product['availability_status']
      online_quantity = product['available_to_promise_quantity']
      if online_quantity > 0 || online_status == "IN_STOCK"
        online_message = "ONLINE STORE has #{online_quantity} on hand. Status: #{online_status}"
        send_sms(online_message)
        return
      end
      locations = product['locations']
      locations.each do |location|
        store = location["store_name"]
        location_status = location['availability_status']
        location_quantity = location['onhand_quantity']
        if location_quantity > 0 || location_status == "IN_STOCK"
          message = "STORE: #{store} has #{location_status} on hand. Status: #{location_status}"
          send_sms(message)
          return
        end
      end
    end
  end

  def send_sms(message)
    client = Twilio::REST::Client.new(ENV["TWILIO_SID"],ENV["TWILIO_TOKEN"])
    client.messages.create(to:ENV["NUM"], from:"+12017771251", body: message)
  end
end
