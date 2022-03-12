class AnalyticsController < ApplicationController
  def enable
    session[:enable_analytics] = true

    redirect_to root_path, notice: "You have enabled your session to be tracked."
  end

  def clear_history
    @user = User.last
    @user.visits.destroy_all

    redirect_to root_path, notice: "History deleted."
  end
end
