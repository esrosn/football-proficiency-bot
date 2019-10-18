require 'json'
require 'twitter'
require 'httparty'
require 'nokogiri'

def lambda_handler(event:, context:)
    twitter = Twitter::REST::Client.new do |config|
        config.consumer_key = ENV['CONSUMER_KEY']
        config.consumer_secret = ENV['CONSUMER_SECRET']
        config.access_token = ENV['ACCESS_TOKEN']
        config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
    end
    
    feeds = ['https://www.soccercoachweekly.net/soccer-drills-and-skills/attacking/feed', 'https://www.goal.com/feeds/en/news', 'https://www.soccercoachweekly.net/feed', 'https://statsbomb.com/articles/feed/', 'https://www.coachesvoice.com/category/masterclass/feed/', 'https://www.coachesvoice.com/category/the-journey/feed/']
    
    latest_tweets = twitter.user_timeline('footballmisters')

    previous_links = latest_tweets.map do |tweet|
        if tweet.urls.any?
            tweet.urls[0].expanded_url
        end
    end
    
    feeds.each do |feed|

        rss = HTTParty.get(feed)
    
        doc = Nokogiri::XML(rss)
    
        site_title = ''
    
        # Get the first title element in the current doc and set site_title to that element's text
        doc.css('title').take(1).each do |item|
            site_title = item.text
        end
       
        # Get the first two item elements from the currect doc and do something with each one
        doc.css('item').take(1).each do |item|
            
            # set title to the item's title element text
            title = item.css('title').text
    
    
            # set title to the item's title element text
            link = item.css('link').text
    
            # set title to the item's title element text
            # category = item.css('category').text
    
            # set creator to the item's createor element
            # creator = item.css('dccreator').text
    
            # puts  "#{site_title} , #{creator}"
    
            # puts site_title.start_with?('Attacking', 'Soccer Coach Weekly') ? "Coach Weekly" : site_title
    
           unless previous_links.include?(link)
                if  site_title.start_with?('Attacking', 'Soccer Coach Weekly' )
                    twitter.update("Digital Coaching: #{title} #{link}")
                elsif site_title.start_with?('Articles – StatsBomb')
                    twitter.update("Analysis: #{title} #{link} via @statsbomb")
                elsif site_title.start_with?('Masterclass')
                    twitter.update("Masterclass: #{title} #{link}  via @coachesvoice")
                elsif site_title.start_with?('The Journey')
                    twitter.update("#{title} #{link} via @coachesvoice")
                else
                    twitter.update("#{title} #{link} via @goal")
                end
           end
    
        end
    end
    { statusCode: 200, body: JSON.generate('Hello from Lambda!') }
end