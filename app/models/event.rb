class Event < ApplicationRecord
  serialize :params
  belongs_to :visitor

  def self.page_views
    select(:path)
      .where(method: "GET")
      .group(:path)
      .count
  end

  def self.unique_page_views
    select(:path)
      .from(
        Event
          .select(:path, :visitor_id)
          .distinct
          .where(method: "GET")
          .group(:path, :visitor_id)
      )
      .group(:path)
      .count(:path)
  end
end
