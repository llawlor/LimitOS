namespace :auto_update do

  desc "run the auto-update ruby script"
  task :run => :environment do
    ruby 'config/auto_update.rb'
  end

end
