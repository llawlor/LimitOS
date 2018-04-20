# require the version file
require_relative 'initializers/version.rb'

# get the current version from GitHub master
remote_version = `git ls-remote https://github.com/llawlor/LimitOS.git refs/heads/master | cut -f 1`

puts "##################"
puts remote_version
puts GIT_VERSION
