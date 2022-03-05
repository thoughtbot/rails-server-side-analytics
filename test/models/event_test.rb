require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "should be valid" do
    @visitor = Visitor.create!
    @event = @visitor.events.build(path: "/", method: "GET")

    assert @event.valid?
  end

  test ".page_views" do
    @visitor_one = Visitor.create!
    @visitor_two = Visitor.create!
    @visitor_three = Visitor.create!

    @visitor_one.events.create!(path: "/", method: "GET")
    @visitor_one.events.create!(path: "/", method: "GET")
    @visitor_two.events.create!(path: "/", method: "GET")
    @visitor_two.events.create!(path: "/", method: "GET")
    @visitor_three.events.create!(path: "/", method: "GET")
    @visitor_one.events.create!(path: "/search", method: "GET")
    @visitor_one.events.create!(path: "/search", method: "GET", params: {q: {name: "Some query"}})
    @visitor_one.events.create!(path: "/search", method: "GET", params: {q: {name: "Another query"}})
    @visitor_two.events.create!(path: "/search", method: "GET", params: {q: {name: "One more query"}})
    @visitor_one.events.create!(path: "/sign_up", method: "POST", params: {contact: {email: "user@example.com"}})

    expected_result = {"/" => 5, "/search" => 4}

    assert_equal expected_result, Event.page_views
  end

  test ".unique_page_views" do
    @visitor_one = Visitor.create!
    @visitor_two = Visitor.create!
    @visitor_three = Visitor.create!

    @visitor_one.events.create!(path: "/", method: "GET")
    @visitor_one.events.create!(path: "/", method: "GET")
    @visitor_two.events.create!(path: "/", method: "GET")
    @visitor_two.events.create!(path: "/", method: "GET")
    @visitor_three.events.create!(path: "/", method: "GET")
    @visitor_one.events.create!(path: "/search", method: "GET")
    @visitor_one.events.create!(path: "/search", method: "GET", params: {q: {name: "Some query"}})
    @visitor_one.events.create!(path: "/search", method: "GET", params: {q: {name: "Another query"}})
    @visitor_two.events.create!(path: "/search", method: "GET", params: {q: {name: "One more query"}})
    @visitor_one.events.create!(path: "/sign_up", method: "POST", params: {contact: {email: "user@example.com"}})

    expected_result = {"/" => 3, "/search" => 2}

    assert_equal expected_result, Event.unique_page_views
  end
end
