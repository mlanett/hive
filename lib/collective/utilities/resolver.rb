# -*- encoding: utf-8 -*-

module Collective::Utilities::Resolver

  # @param classname
  # @returns class object
  def resolve_class(classname)
    classname.split(/::/).inject(Object) { |a,i| a.const_get(i) }
  end

  extend Collective::Utilities::Resolver
end
