require "test_helper"

class VisitorTest < ActiveSupport::TestCase
  test ".time_on_site" do
    freeze_time

    @visitor_one = Visitor.create!(id: 1)
    @visitor_one.events.create!(path: "/", method: "GET")

    @visitor_two = Visitor.create!(id: 2)
    @visitor_two.events.create!(path: "/", method: "GET")

    @visitor_three = Visitor.create!(id: 3)
    @visitor_three.events.create!(path: "/", method: "GET")

    travel_to 1.minute.from_now
    @visitor_one.events.create!(path: "/search", method: "GET")

    travel_to 1.hour.from_now
    @visitor_two.events.create!(path: "/search", method: "GET")

    travel_to 1.month.from_now

    expected_results = [
      [3, 0.0], [1, 60.0], [2, 3660.0]
    ]

    assert_equal expected_results.sort, Visitor.time_on_site.sort
  end
end
