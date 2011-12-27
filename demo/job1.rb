require "collective"

=begin

  Mostly does nothing.
  Otherwise runs in 1-10 seconds.

=end

class Job1
  
  def initialize( options = {} )
  end
  
  include Collective::Log
  
  def call(context)
    p = rand
    
    case
    when p < 0.7 # 10%
      log "No action"
      false
    else
      log "Something"
      sleep(rand(10))
      true
    end
  end
  
end # Job1
