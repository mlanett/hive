# -*- encoding: utf-8 -*-

module Hive::Utilities::Observeable

  def add_observer(o)
    (@observers ||= []).push(o)
  end

  def notify( *details )
    (@observers || []).each do |observer|
      observer.notify( self, *details )
    end
  end

end