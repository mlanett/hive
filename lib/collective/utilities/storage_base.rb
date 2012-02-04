# -*- encoding: utf-8 -*-

class Hive::Utilities::StorageBase

  module Resolver
    # resolution is as so:
    # nil, :mock => :mock
    # :redis     => redis://127.0.0.1:6379/1
    # string     => CLASS.new
    # CLASS      => CLASS.new
    # PROC       => yield (recursive)
    # [ ARRAY ]  => first, *args (recursive)
    def resolve( storage, *args )
      storage ||= :mock
      case
      when storage.respond_to?(:call)
        resolve(storage.call(*args))
      else
        case storage
        when :mock
          resolve( Hive::Mocks::Storage, *args )
        when :redis
          resolve( Hive::Redis::Storage, *args )
        when Class
          storage.new(*args)
        when String
          resolve( Hive::Utilities::Resolver.resolve_class(storage), *args )
        when Array
          args    = storage.dup + args
          storage = args.shift
          resolve( storage, *args )
        else
          return storage
        end
      end
    end # resolve
  end # Resolver

  extend Resolver

end # Hive::Utilities::StorageBase
