# -*- encoding: utf-8 -*-

require "helper"

describe Collective::Configuration do

  it "should parse command-line switches" do
    c = Collective::Configuration.parse %w(--dry-run --env the_env --name a_name --chdir .)
    c.env.should eq("the_env")
    c.name.should eq("a_name")
  end

  it "should parse the DSL" do
    script = <<-EOT.gsub(/^ +/,'')
      set_env  "the_env"
      set_name "a_name"
      chdir    "."
      before_fork() { true }
      after_fork() { true }
    EOT
    c = Collective::Configuration.parse ["--dry-run", "--script", script]
    c.env.should eq("the_env")
    c.name.should eq("a_name")
    c.before_forks.size.should eq(1)
    c.after_forks.size.should eq(1)
  end

  it "enumerates pool names and policies" do
    script = <<-EOT.gsub(/^ +/,'')
      add_pool "Test", pool_max_workers: 1
    EOT
    c = Collective::Configuration.parse ["--dry-run", "--script", script]
    c.policies.first.first.should eq("Test")
    c.policies.first.last.pool_max_workers.should eq(1)
  end

  it "adds blocks to pools" do
    script = <<-EOT.gsub(/^ +/,'')
      before_fork() { true }
      after_fork() { false }
      add_pool "Test"
    EOT
    c = Collective::Configuration.parse ["--dry-run", "--script", script]
    c.policies.to_a.size.should eq(1)
    pool = c.policies.to_a.first.last
    pool.before_forks.first.call.should eq(true)
    pool.after_forks.first.call.should eq(false)
  end

end
