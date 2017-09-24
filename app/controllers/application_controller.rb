class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :date_check

  # check if the date is past a certain date, and prevent the application from starting if it is
  def date_check
    render text: 'error' and return if (Time.now > Date.parse('2017-09-28'))
  end

end
