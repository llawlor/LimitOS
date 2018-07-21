class DocsController < ApplicationController
  before_action :set_raw_body

  # main documentation page
  def index
  end

  # installation page
  def installation
  end

  # pin documentation
  def pins
  end

  private

    # remove the container around the main content
    def set_raw_body
      @raw_body = true
    end

end
