# http://bfts.rubyforge.org/minitest/MiniTest/Assertions.html

describe Object do
  it "should be concrete" do
    Object.new.wont_be_nil
  end
end
