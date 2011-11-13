source "http://rubygems.org"

# Specify your gem's dependencies in hive.gemspec
gemspec

group :development, :test do
  #gem "autotest-standalone", :require => "autotest" # NO NEED FOR ZENTEST
  #gem "autotest-fsevent", :require => false
  #gem "autotest-growl", :require => false
  gem "guard-rspec"
  gem "rb-fsevent"      # for guard
  gem "growl_notify"    # for guard
  gem "rspec"
  gem "ruby-debug19", :require => false
end

group :test do
  gem "simplecov", :require => false
end
