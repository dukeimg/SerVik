require "rails_helper"

RSpec.describe Game, :type => :model do
  it "case 1" do
    expect(Game.crypt('1737', '2751')).to eq('2:1')
  end

  it "case 2" do
    expect(Game.crypt('2737', '7274')).to eq('3:0')
  end

  it "case 3" do
    expect(Game.crypt('2737', '2274')).to eq('2:1')
  end

  it "case 4" do
    expect(Game.crypt('2234', '4322')).to eq('4:0')
  end

  it "case 5" do
    expect(Game.crypt('2223', '2000')).to eq('1:1')
  end

  it "case 6" do
    expect(Game.crypt('2000', '2223')).to eq('1:1')
  end

  it "judges properly" do
    expect(Game.crypt('2751', '2751')).to eq('4:4')
  end
end