class PagesController < ApplicationController
  include TrackEvent

  before_action :track_event

  def contact
  end

  def home
  end

  def search
  end

  def sign_up
  end
end
