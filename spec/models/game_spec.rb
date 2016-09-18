require "rails_helper"

RSpec.describe Game, :type => :model do
  it "alanyses the code" do
    expect(Game.crypt('1737', '2751')).to eq('2:1')
  end

  it "judges properly" do
    expect(Game.crypt('2751', '2751')).to eq('4:4')
  end
end