require "rails_helper"

RSpec.describe Game, :type => :model do
  it "case 1" do
    expect(Game.crypt('1737', '2751')).to eq('2:1')
  end

  it "case 2" do
    expect(VirtualGame.crypt('2737', '7274')).to eq('3:0')
  end

  it "case 3" do
    expect(VirtualGame.crypt('2737', '2274')).to eq('3:1')
  end

  it "case 4" do
    expect(VirtualGame.crypt('2737', '2274')).to eq('3:1')
  end

  it "case 5" do
    expect(VirtualGame.crypt('2223', '2000')).to eq('1:1')
  end

  it "judges properly" do
    expect(Game.crypt('2751', '2751')).to eq('4:4')
  end
end