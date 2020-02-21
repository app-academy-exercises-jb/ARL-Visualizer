class ApplicationController < ActionController::Base
  helper_method :get_ip
  
  def index
    render :index
  end

  def get_ip
    request.remote_ip
  end
end
