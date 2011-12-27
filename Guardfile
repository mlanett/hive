guard "rspec" do
  watch(%r{^lib/collective\.rb$})       { "spec" }
  watch(%r{^lib/collective/(.+)\.rb$})  { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb$})
  watch("spec/helper.rb")         { "spec" }
end
