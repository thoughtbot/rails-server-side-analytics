module TrackEvent
  extend ActiveSupport::Concern

  def track_event
    Current.visitor.events.create(
      path: request.path,
      method: request.method,
      params: filter_sensitive_data(event_params)
  end

  private

  def filter_sensitive_data(params)
    return if params.nil?

    ActiveSupport::ParameterFilter.new(
      Rails.application.config.filter_parameters
    ).filter(params)
  end

  def event_params
    request.query_parameters.presence || request.request_parameters.presence
  end
end