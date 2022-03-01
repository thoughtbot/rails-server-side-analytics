class AnalyticsController < ApplicationController
  def enable
    session[:enable_analytics] = true

    redirect_to root_path, notice: "You have enabled your session to be tracked."
  end
end
