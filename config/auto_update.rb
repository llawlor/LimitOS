# require the version file
require_relative 'initializers/version.rb'

# get the current version from GitHub master
remote_version = `git ls-remote https://github.com/llawlor/LimitOS.git refs/heads/master | cut -f 1`

puts "##################"
puts remote_version
puts GIT_VERSION

# if the remote version is not the same as the local version
if remote_version != GIT_VERSION
  # initialize the repository
  `git init`
  # add the remote
  `git remote add origin https://github.com/llawlor/LimitOS.git`
  # get the branch data
  `git fetch`
  # revert local changes
  `git reset origin/master`
  # switch to the master branch
  `git checkout origin/master`
  # restart the webserver
  
end
