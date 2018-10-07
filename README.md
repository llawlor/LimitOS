# LimitOS
Websocket control for IoT devices: https://limitos.com .

## Installation

Installation steps:
TODO

After the LimitOS application has been installed, run the following command so that automated tasks are run correctly:
bundle exec whenever --update-crontab limitos --set environment=production --roles=app,web,db

### Auto-Update Functionality
Every 5 minutes, the LimitOS application will automatically attempt to update to the latest "master" branch version on GitHub at https://github.com/llawlor/LimitOS .  Please be aware that by running an installation of LimitOS you are explicity agreeing to this functionality.
