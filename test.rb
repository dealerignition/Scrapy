require 'scrapy'

scraper = Scrapy::Crawler::new("http://www.breakawayhonda.com", 
                               [{:location=>'vehicleInfo',:type=>'id',:name=>'Product Name'},
                                {:location=>"ul[@id='vehicleDetails']/li[9]",:type=>"custom",:name=>"Stock #"}]) 
scraper.crawl
while not scraper.crawling_complete
  sleep(30)
  puts "Polling..."
end

scraper.retrieve_products.each do |scraped|
  puts "->#{scraped["Product Name"]} = # #{scraped["Stock #"]}"
end
puts "Done!"
