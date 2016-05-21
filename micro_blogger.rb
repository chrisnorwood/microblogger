require 'bitly'
Bitly.use_api_version_3
require 'jumpstart_auth'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initalizing..."
    @client = JumpstartAuth.twitter
  end

  def tweet message
    if message.length <= 140
      @client.update(message)  
    else
      raise "Tweet is too long.  Did not post."
    end
  end

  def dm target, message
    puts "Trying to send #{target} this direct message:"
    puts message
    
    message = "d @#{target} #{message}"
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name}

    if screen_names.include?(target)
      tweet(message)
    else
      raise "You can only direct message your followers."
    end
  end

  # returns array of followers
  def followers_list
    screen_names = []
    @client.followers.each do |follower|
      screen_names << @client.user(follower).screen_name
    end
    screen_names
  end

  def spam_my_friends message
    followers = followers_list
    followers.each do |follower|
      dm(follower, message)
    end
  end

  def everyones_last_tweet
    friends = @client.friends.map { |friend| @client.user(friend).screen_name }
    friends.sort_by! { |friend| friend.downcase }
    friends.each do |friend|
      status = @client.user(friend).status
      date = @client.user(friend).created_at.strftime("%A %b %d")
      puts "#{friend} said this on #{date}..."
      puts status.text
      puts ""
    end
  end

  def shorten original_url
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    return bitly.shorten(original_url).short_url
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
      when 'q'  then puts "Goodbye!"
      when 't'  then tweet(parts[1..-1].join(" "))
      when 'dm' then dm(parts[1], parts[2..-1].join(" "))
      when 'spam' then spam_my_friends(parts[1..-1].join(" "))
      when 'elt' then everyones_last_tweet
      when 's' then shorten(parts[-1])
      when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end
  end
end

blogger = MicroBlogger.new
blogger.run