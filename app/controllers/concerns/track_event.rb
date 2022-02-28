module TrackEvent
  extend ActiveSupport::Concern

  def track_event
    Current.visitor.events.create(
      path: request.path,
      method: request.method,
      params: event_params
    )
  end

  private

  def event_params
    request.query_parameters.presence || request.request_parameters.presence
  end
end