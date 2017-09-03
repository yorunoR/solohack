class EventsController < ApplicationController

  def check
  end
  def check2
  end

  def search
    words = params[:words]
    expr  = params[:expr]
    num   = params[:num].to_i || 100

    if expr == "or"
      query =  words.join(" OR ")
    else
      query =  words.join(" ")
    end

    #since_id = nil

    result_tweets = $client.search(
      query,
      count:50,
      #result_type:"recent",
      exclude:"retweets",
      #src:"typd",
      #since_id: since_id
    )
    search_tws = result_tweets.take(num).map do |tweet|
      #pt tweet.user.screen_name + ':' + tweet.text
      {
        :name => tweet.user.screen_name,
        :text => tweet.text,
        :user => tweet.user
      }
    end

    users = check_follower
    already_users = $mng_users.find({},:fields => ["user_id"]).to_a
    already = already_users.map do | user |
      user['user_id'].to_i
    end

    result = search_tws.select do | twit |
      !users.include?(twit[:user].id) && !already.include?(twit[:user].id)
    end

    render :json => { :response => result }
  end

  def follow
    users = params[:users]
    datas = params[:datas]

    time = Time.now - 7.days
    #time = Time.now
    users.each do | id |
      pt id
      $client.follow(id.to_i)
      $mng_users.insert({user_id:id, time:time, datas:datas[id]})
    end
    render :json => { :response => users }
  end

  def users
    num = params[:num]
    time = Time.now - num.to_i.days
    result = $mng_users.find({:time => {"$lt" => time}}).to_a

    users = check_follower
    result.map do |user|
      if users.include?(user['user_id'].to_i)
        user['follower_flag'] = true
      else
        user['follower_flag'] = false
      end
    end

    render :json => { :response => result }
  end

  def delete
    dels = params[:del]
    pt dels
    dels.each do | user_id |
      $mng_users.remove(:user_id => user_id)
      $client.unfollow(user_id.to_i)
    end
    render :json => { :response => dels.length }
  end

  private

    def check_follower
      time = Time.now
      if time > ( $pre_time + 15.minute )
        result = $client.follower_ids(ENV["TWITTER_USER"]).to_a
        $pre_time = time
        tid = time.to_i
        $mng_followers.insert({tid:tid, followers:result})
      else
        #tid = $pre_time.to_i
        #followers = $mng_followers.find({tid:tid}).
        followers = $mng_followers.find.sort(:tid).first
        result = followers['followers']
      end
      return result
    end

end
