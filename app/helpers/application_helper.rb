module ApplicationHelper

  # full url of the server, for example: https://limitos.com or http://localhost:3000
  def full_url
    "http#{ 's' if Rails.env.production?}://#{request.host_with_port}"
  end

end
