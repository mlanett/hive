# -*- encoding: utf-8 -*-

module Hive::Utilities::Observeable

  def add_observer(o)
    o.focus(self)
    (@observers ||= []).push(o)
  end

  def notify( *details )
    if @observers then
      @observers.each do |observer|
        observer.notify( self, *details )
      end
    end
  end

end
