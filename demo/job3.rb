require "hive"

=begin

  Sometimes does something but is slow.

=end

class Job3
  
  def initialize( options = {} )
  end
  
  include Hive::Log
  
  def call(context)
    p = rand
    
    case
    when p < 0.1 # 10%
      sleep(rand(60))
      true
    else
      false
    end
  end
  
end # Job3
