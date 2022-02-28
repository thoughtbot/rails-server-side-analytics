class CreateEventJob < ApplicationJob
  queue_as :default

  def perform(visitor:, path:, method:, params:)
    visitor.events.create!(
      path: path,
      method: method,
      params: params
    )
  end
end
