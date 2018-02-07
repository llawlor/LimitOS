class Api::V1::DevicesController < ApplicationController
  skip_before_action :verify_authenticity_token

  # create a new device
  def create
    render text: 'create device'
  end

end
