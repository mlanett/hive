require "hive"

=begin

  Does nothing, quickly.

=end

class Hive::Utilities::NullJob

  def call(context)
    true
  end

end # Hive::Utilities::NullJob
