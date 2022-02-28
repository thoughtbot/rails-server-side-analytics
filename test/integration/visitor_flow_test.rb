require "test_helper"

class VisitorFlowTest < ActionDispatch::IntegrationTest
  test "should create visitor and track their events in the background" do
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
end
