class GamesController < ApplicationController

  before_action :redirect_mobile, only: :welcome

  def welcome
    respond_to do |format|
      format.html {render 'games/welcome'}
    end
  end

  private

  def redirect_mobile
    if is_mobile_request?
      redirect_to download_path
    end
  end
end
