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
end

blogger = MicroBlogger.new
blogger.tweet("less than 140")
blogger.tweet("".ljust(140, "abcd"))
blogger.tweet("".ljust(160, "abcd"))