class ApplicationController < ActionController::Base
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access Denied."
    redirect_to root_url
  end
end
