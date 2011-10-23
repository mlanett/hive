# -*- encoding: utf-8 -*-

module Hive::Utilities::Observer

  # can implement notify( observeable, *details )
  # or can use this implementation

  def notify( observeable, *details )
    if self.respond_to?(details.first) then
      details = details.dup
      self.send( details.shift, *details )
    end
  end

end
