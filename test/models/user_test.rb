require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    @user = User.new(email: "user@example.com")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "#time_on_site" do
    freeze_time do
      @user.save!

      @visit_one = @user.visits.create!
      @visit_two = @user.visits.create!

      @visit_one.events.create!(path: "/", method: "GET")

      travel_to 1.minute.from_now
      @visit_one.events.create!(path: "/search", method: "GET")

      travel_to 1.hours.from_now
      @visit_one.events.create!(path: "/", method: "GET")

      travel_to 1.week.from_now

      @visit_two.events.create!(path: "/", method: "GET")

      travel_to 1.minute.from_now
      @visit_two.events.create!(path: "/search", method: "GET")

      travel_to 1.hours.from_now
      @visit_two.events.create!(path: "/", method: "GET")

      assert_equal 7320, @user.time_on_site
    end
  end

  test "#average_time_on_site" do
    freeze_time do
      @user.save!

      @visit_one = @user.visits.create!
      @visit_two = @user.visits.create!

      @visit_one.events.create!(path: "/", method: "GET")

      travel_to 1.minute.from_now
      @visit_one.events.create!(path: "/search", method: "GET")

      travel_to 1.hours.from_now
      @visit_one.events.create!(path: "/", method: "GET")

      travel_to 1.week.from_now

      @visit_two.events.create!(path: "/", method: "GET")

      travel_to 30.minutes.from_now
      @visit_two.events.create!(path: "/", method: "GET")

      assert_equal 2730, @user.average_time_on_site
    end
  end

  test "#events" do
    @user.save!

    @visit_one = @user.visits.create!
    @visit_two = @user.visits.create!

    @visit_one.events.create!(path: "/", method: "GET")
    @visit_two.events.create!(path: "/", method: "GET")

    @visit_one.events.create!(path: "/search", method: "GET")
    @visit_one.events.create!(path: "/search", method: "GET", params: {q: {name: "some-query"}})
    @visit_two.events.create!(path: "/search", method: "GET", params: {q: {name: "another-query"}})

    @visit_two.events.create!(path: "/sign_up", method: "POST")

    assert_equal 6, @user.events.count
  end

  test "destroy associated records when destroyed" do
    @user.save!
    @visit = @user.visits.create!
    @visit.events.create!(path: "/", method: "GET")

    assert_difference -> { Event.count } => -1, -> { Visitor.count } => -1 do
      @user.destroy!
    end
  end
end
