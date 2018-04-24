# require the version file
require_relative 'initializers/version.rb'

# get the current version from GitHub master
remote_version = `git ls-remote https://github.com/llawlor/LimitOS.git refs/heads/master | cut -f 1`

# if the git versions are present and the remote version is not the same as the local version
if !GIT_VERSION.nil? && GIT_VERSION.length > 0 && !remote_version.nil? && remote_version.length > 0 && remote_version.strip != GIT_VERSION.strip
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

  # install the necessary gems
  `bundle install`

  # run database migrations
  `RAILS_ENV=production bundle exec rake db:migrate`

  # set up scheduled tasks
  `bundle exec whenever --update-crontab limitos --set environment=production --roles=app,web,db`

  # check if phusion passenger is running (via nginx)
  phusion_passenger_is_running = (`ps aux | grep nginx | grep -v grep | wc -l`.to_i > 0)
  # check if puma is running
  puma_is_running = (`ps aux | grep puma | grep -v grep | wc -l`.to_i > 0)

  # if phusion passenger is running
  if phusion_passenger_is_running
    # restart the webserver
    `touch tmp/restart.txt`
  end

  # if puma is running
  if puma_is_running
    # get the process ID
    puma_process_id = `ps aux | grep puma | grep -v grep | grep -v clust | awk '{print $2}'`.to_i
    # restart the webserver if the process ID is greater than 0
    `kill -SIGUSR1 #{puma_process_id}` if puma_process_id > 0
  end

end
