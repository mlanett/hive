describe Hive::Configuration do

  it "should parse command-line switches" do
    c = Hive::Configuration.parse %w(--dry-run --env the_env --name a_name --chdir .)
    c.env.must_equal "the_env"
    c.name.must_equal "a_name"
  end

  it "should parse the DSL" do
    script = <<-EOT.gsub(/^ +/,'')
      set_env  "the_env"
      set_name "a_name"
      chdir    "."
    EOT
    c = Hive::Configuration.parse ["--dry-run", "--script", script]
    c.env.must_equal "the_env"
    c.name.must_equal "a_name"
  end

end
