require "hive"

=begin

  Sometimes exits, hangs, or aborts.
  Otherwise does something.

=end

class Job2
  
  def initialize( options = {} )
  end
  
  include Hive::Log
  
  def call(context)
    p = rand
    
    case
    when p < 0.1 # 10%
      log "Going to exit"
      exit
    when p < 0.2 # 10%
      log "Hang"
      loop do
        true
      end
    when p < 0.3 # 10%
      log "Going to abort"
      abort!
    when p < 0.9 # 60%
      log "Nothing to do"
      false
    else         # 10%
      log "Doing something..."
      sleep(rand(10))
      true
    end
  end
  
end # Job2
