require "rails_helper"

RSpec.describe VirtualGame, :type => :model do
  it "alanyses the code" do
    expect(VirtualGame.crypt('1737', '2751')).to eq('2:1')
  end

  it "handles digits repeating" do
    expect(VirtualGame.crypt('2737', '7274')).to eq('3:0')
  end

  it "judges properly" do
    expect(VirtualGame.crypt('2751', '2751')).to eq('4:4')
  end
end