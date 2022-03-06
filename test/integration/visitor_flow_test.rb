require "test_helper"

class VisitorFlowTest < ActionDispatch::IntegrationTest
  test "should create visitor and track their events in the background" do
    enable_analytics

    assert_difference -> { Visitor.count } => 1, -> { Event.count } => 1 do
      assert_enqueued_with(job: CreateEventJob) do
        get root_path, headers: {"User-Agent" => "Some User Agent"}
      end
      perform_enqueued_jobs
    end

    assert_not_nil Visitor.last.user_agent
    assert_equal Visitor.last, Event.last.visitor
    assert_equal root_path, Event.last.path
    assert_nil Event.last.params
    assert_equal "GET", Event.last.method

    assert_difference -> { Visitor.count } => 0, -> { Event.count } => 1 do
      assert_enqueued_with(job: CreateEventJob) do
        post contact_path, params: {
          contact: {
            email: "user@example.com",
            name: "Some User"
          }
        }
      end
      perform_enqueued_jobs
    end

    assert_equal Visitor.last, Event.last.visitor
    assert_equal contact_path, Event.last.path
    assert_equal "user@example.com", Event.last.params[:contact][:email]
    assert_equal "Some User", Event.last.params[:contact][:name]
    assert_equal "POST", Event.last.method

    assert_difference -> { Visitor.count } => 0, -> { Event.count } => 1 do
      assert_enqueued_with(job: CreateEventJob) do
        get search_path, params: {
          q: {
            name: "Some search",
            order: "desc"
          }
        }
      end
      perform_enqueued_jobs
    end

    assert_equal Visitor.last, Event.last.visitor
    assert_equal search_path, Event.last.path
    assert_equal "Some search", Event.last.params[:q][:name]
    assert_equal "desc", Event.last.params[:q][:order]
    assert_equal "GET", Event.last.method
  end

  test "should filter sensative data from params" do
    enable_analytics

    assert_enqueued_with(job: CreateEventJob) do
      post sign_up_path, params: {
        user: {
          email: "user@example.com",
          password: "password",
          password_confirmation: "password",
          credit_card_number: "4242 4242 4242 4242"
        }
      }
    end

    perform_enqueued_jobs

    assert_equal "[FILTERED]", Event.last.params[:user][:password]
    assert_equal "[FILTERED]", Event.last.params[:user][:password_confirmation]
    assert_equal "[FILTERED]", Event.last.params[:user][:credit_card_number]
  end

  test "should respects a visitor's privacy" do
    assert_no_difference ["Visitor.count", "Event.count"] do
      assert_no_enqueued_jobs do
        get root_path, headers: {"User-Agent" => "Some User Agent"}
      end
    end

    assert_select "button", "Enable Analytics"

    post enable_analytics_path

    assert_difference -> { Visitor.count } => 1, -> { Event.count } => 1 do
      assert_enqueued_with(job: CreateEventJob) do
        get root_path, headers: {"User-Agent" => "Some User Agent"}
      end
      perform_enqueued_jobs
    end

    assert_select "button", count: 0, text: "Enable Analytics"
  end

  test "should track conversions if analytics are enabled" do
    enable_analytics

    perform_enqueued_jobs do
      get root_path

      assert_difference("User.count") do
        post sign_up_path, params: {
          user: {
            email: "user@example.com"
          }
        }
      end

      assert_equal User.last, Visitor.last.user
    end
  end

  test "should not track events if analytics are disabled" do
    perform_enqueued_jobs do
      get root_path

      assert_difference("User.count") do
        post sign_up_path, params: {
          user: {
            email: "user@example.com"
          }
        }
      end

      assert_equal 0, Visitor.count
    end
  end

  test "should associate user with visitor when user creates a new session if analytics are enabled" do
    enable_analytics

    @user = User.create!(email: "user@example.com")

    perform_enqueued_jobs do
      post sign_in_path, params: {
        user: {
          email: "user@example.com"
        }
      }

      assert_equal @user, Visitor.last.user
    end
  end
end
