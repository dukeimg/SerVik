class GamesController < ApplicationController
  def welcome
    respond_to do |format|
      format.html {render 'games/welcome'}
    end
  end
end
