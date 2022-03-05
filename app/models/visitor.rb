class Visitor < ApplicationRecord
  has_many :events

  def self.time_on_site
    select("visitor_id, lower_bounds, upper_bounds")
      .from(
        Event
          .select(
            "visitor_id,
            MIN(created_at) AS lower_bounds,
            MAX(created_at) AS upper_bounds"
          )
          .group(:visitor_id)
      )
      .pluck(
        "visitor_id",
        Arel.sql("EXTRACT(EPOCH FROM (upper_bounds - lower_bounds))")
      )
      .sort
  end
end
