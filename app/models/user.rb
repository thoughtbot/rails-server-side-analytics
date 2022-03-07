class User < ApplicationRecord
  has_many :visits, class_name: "Visitor"
  has_many :events, through: :visits

  def time_on_site
    Visitor.total_time_on_site_for_visitor(visits)
  end

  def average_time_on_site
    Visitor.average_time_on_site_for_visitor(visits)
  end
end
