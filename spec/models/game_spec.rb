require "rails_helper"

RSpec.describe Game, :type => :model do
  # code: '2751'

  it "alanyses the code" do
    data = {'msg' => '1737'}
    expect(Game.turn(1, data)).to eq('2:1')
  end

  it "judges properly" do
    data = {'msg' => '2751'}
    expect(Game.turn(1, data)).to eq('4:4')
  end
end