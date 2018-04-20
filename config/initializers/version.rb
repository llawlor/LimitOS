# get the hash of the last git commit
def git_version
  # get the version from git
  version = `git rev-parse HEAD`.strip
  # get the version from the REVISION file if the version using git is blank (due to an error message)
  # don't use ".blank?" since this file is used outside of rails via auto_update.rb
  version = `cat REVISION`.strip if version.nil? || version.length == 0
  # return the git version
  return version
end

# use a constant to save the git version of the application, since it will only change when the application is reloaded
GIT_VERSION = git_version
