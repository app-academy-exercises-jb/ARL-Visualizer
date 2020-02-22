class ApplicationController < ActionController::Base
  helper_method :get_ip, :get_classes

  def index
    render :index
  end

  def get_ip
    request.remote_ip
  end

  def get_classes
    ensure_connection()
    BaseConnection.classes
  end

  def ensure_connection
    unless BaseConnection.loaded == true
      BaseConnection.connect()
    end
  end
end
