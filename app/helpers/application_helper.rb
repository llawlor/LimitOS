module ApplicationHelper

  # full url of the server, for example: https://limitos.com or http://localhost:3000
  def full_server_url
    return "http#{ 's' if Rails.env.production?}://#{request.host_with_port}"
  end

  # meta tag for images, so that thumbnails appear correctly on social media
  def image_meta_tag(image_path)
    return "<meta property='og:image' content='#{ asset_url(image_path) }' />".html_safe
  end

end
