guard "rspec" do
  watch(%r{^lib/hive\.rb$})       { "spec" }
  watch(%r{^lib/hive/(.+)\.rb$})  { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
  watch("spec/helper.rb")         { "spec" }
end
