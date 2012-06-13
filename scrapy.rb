require 'rubygems'
require 'anemone'
require 'hpricot'
require 'open-uri'

module Scrapy
  class Crawler
    #initialize
    #takes a uri of the format http://www.url.com and returns
    #a Crawler object that is ready to crawl
    #classes must have the form =>
    #[{
    #  :location=>"class/id name | html location (i.e. ul[@class='vehicleDescription']/li[9])",
    #  :type=>"custom | class | id"
    #  :name=>"Name"
    #}]
    def initialize(base_url, classes)
      @classes = classes
      @base_url = base_url

      @located_products = []
      @completed = false
      @crawling = false
    end

    #returns true if crawling has finished
    #false otherwise
    def crawling_complete
      @completed
    end

    #returns true if crawling is currently happening
    #false otherwise
    def is_crawling
      @crawling
    end

    #returns the list of products retrieved if
    #crawler has finished, otherwise throws exception
    def retrieve_products
      if @completed
        @located_products
      else
        raise "The crawler has not yet completed.  Check .crawl_complete before attempting to receive products."
      end
    end

    #spawn a new thread to crawl the website using the given rules
    def crawl
      if not @crawling
        @completed = false
        @located_products = []
        
        @thread = Thread.new { 
          traverse(@base_url) 
          @crawling = false
          @completed = true
        }

        @crawling = true
      else
        raise "Already crawling.  Stop current crawl job before starting another."
      end
    end

    def force_stop
      @thread.kill
      @crawling = false
      @completed = false
    end

    def cleanup
      if @completed
        @thread.join
      end
    end

    private
    def traverse(url)
      urls = []
      Anemone.crawl(url) do |anemone|
        anemone.on_every_page do |page|
          urls << page.url
        end
      end

      urls.uniq!
   
      urls.each do |url_i|
        begin
          webpage = Hpricot(open(url_i, 'User-Agent' => 'ruby'))
          
          map = {}
          found = true
          @classes.each do |item|
            if item[:type] == 'custom'
              div = webpage.search("body").search("[@#{item[:type]}~='#{item[:location]}']")
              if div.length != 0
                map[item[:name]] = div[0].inner_text
              else
                found = false
              end
            else
              div = (webpage/item[:location]).inner_text
              if div != nil
                map[item[:name]] = div
              else
                found = false
              end
            end
          end
          
          if found
            map[:page_url] = url_i
            @located_products << map
          end
        rescue Exception => e
          puts e.message
        end
      end
    end
  end
end
