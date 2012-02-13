# -*- encoding: utf-8 -*-

=begin
  Gives you assert_valid_keys without infecting Hash
=end

module Hive::Utilities::Hash

  def assert_valid_keys( hash, *valid_keys )
    hash.each_key do |key|
      raise(ArgumentError, "Unknown key: #{key}") unless valid_keys.include?(key)
    end
  end

end
