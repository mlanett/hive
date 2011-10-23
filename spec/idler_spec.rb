describe Hive::Idler do

  it "should not run idle tasks too much" do
    count  = 0
    idle   = Hive::Idler.new { count += 1; false }
    finish = Time.now.to_f + 1
    idle.call until finish < Time.now.to_f
    count.must_be :<=, 10
  end

end
