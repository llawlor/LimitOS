module ApplicationHelper

  # full url of the server, for example: https://limitos.com or http://localhost:3000
  def full_url
    "http#{ 's' if Rails.env.production?}://#{request.host_with_port}"
  end

  # get the hash of the last git commit
  def git_version
    # get the version from git
    version = `git rev-parse HEAD`.strip
    # get the version from the REVISION file if the version using git is blank (due to an error message)
    version = `cat REVISION`.strip if version.blank?
    # return the git version
    return version
  end

end
