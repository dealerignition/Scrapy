#Flexible Web Crawler designed for Product Scraping#

##Dependencies##
* open-uri
* openssl
* hpricot
* anemone

##Usage##
1. Create a list of hash describing the objects to search for.

```
[{
  :location=>"class/id name | html location (i.e. ul[@class='vehicleDescription']/li[9])",
  :type=>"custom | class | id"
  :name=>"Name"
}]
```
2. Instantiate a copy of the scraper.

```
scraper = Scrapy::Crawler.new(<website url>, options)
```

3. Start the crawl session.

```
scraper.crawl
Note: this call will return immediately, but crawling will take some time
```

4. You can poll the crawler to see if it has finished

```
scraper.crawling_complete? => boolean
```

5. Once crawling has finished, use retrieve_products to receive a list of products matched.

```
scrapper.receive_products
Note: each item will be under scrapper[0][:Name], page_url is scrapper[0][:page_url]
```