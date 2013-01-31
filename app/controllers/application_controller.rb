class ApplicationController < ActionController::Base
  protect_from_forgery

  # Returns the default view information reported by
  def default_reported_by
    'funders'
  end

  def default_institution_reported_by
    'self'
  end
end
