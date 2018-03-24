puts "starting update script"

# get the latest
`git checkout master`
`git pull origin master`

# update gems
`RAILS_ENV=production bundle install --path /u/apps/limitos/shared/bundle --without development test --deployment --quiet`

# migrate the database
`RAILS_ENV=production rake db:migrate`

# restart the server
`passenger-config restart-app /u/apps/limitos --ignore-app-not-running`
