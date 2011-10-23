describe Hive::Idler do

  it "should not run idle tasks too much" do
    count  = 0
    Hive::Idler.wait { count += 1; false }
    count.must_be :<=, 10
  end

end
