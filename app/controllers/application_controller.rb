class ApplicationController < ActionController::Base
  include Mobylette::RespondToMobileRequests

  protect_from_forgery with: :exception
  before_action :get_url, :set_locale, :redirect_mobile
  skip_before_action :redirect_mobile, :if => lambda{params[:skip]}

  def default_url_options(options = {})
    { :locale => I18n.locale }
  end

  def root
    redirect_to play_path
  end

  private
  def get_url
    @url = request.original_url.remove('/en', '/ru')
  end

  def set_locale
    I18n.locale = params[:locale] || http_accept_language.compatible_language_from(I18n.available_locales) || :en
    @lang = I18n.locale.to_s
  end

  def redirect_mobile
    if is_mobile_request?
      redirect_to download_path(:skip => true)
    end
  end
end
