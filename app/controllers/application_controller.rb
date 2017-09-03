class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  $db = Mongo::Connection.new['tw']
  $mng_users = $db['users']
  $mng_followers = $db['followers']

  $client = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  end

  init_follower = $mng_followers.find.sort(:tid).first
  if init_follower == nil
    init_follower = $client.follower_ids(ENV["TWITTER_USER"]).to_a
    $pre_time = Time.now
    $mng_followers.insert({tid:$pre_time.to_i, followers:init_follower})
  else
      $pre_time = Time.at(init_follower['tid'])
  end

  def pt obj
    if obj == false
      logger.debug obj.to_s
    else
      logger.debug obj
    end
  end

end
