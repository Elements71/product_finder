namespace :best_buy do
  desc 'find switch'
  task :find_switch => :environment do
    switch_array = [5670003, 5670100]
    switch_array.each do |sku_id|
      url = "http://www.bestbuy.com/fulfillment/ispu/api/ispu/byLocation/sku;showUnavailableLocations=true;showInStore=true;skuId=#{sku_id};locationId=1115"
      response = RestClient.get(url, {"X-CLIENT-ID"=>"BROWSE"})
      json = JSON.parse(response).first
      json['pickupEligible']
      json['locations']
      send_sms("FLUSHING Best Buy: instock")
    end

  end

  def send_sms(message)
    client = Twilio::REST::Client.new(ENV["TWILIO_SID"],ENV["TWILIO_TOKEN"])
    client.messages.create(to:ENV["NUM"], from:"+12017771251", body: message)
  end
end



