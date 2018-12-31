# LimitOS
Websocket control for IoT devices: https://limitos.com .

## Client Installation Notes
To use LimitOS with your Raspberry Pi, please see the installation documentation at https://limitos.com/docs/installation .

## Self-Hosted Server Installation Notes
If you're running your own server, you can modify some configuration settings at config/limitos.yml .  Please note the commercial limitations when running your own server, which can be found at https://limitos.com/ .

After the LimitOS application has been installed, run the following command so that automated tasks are run correctly:

`bundle exec whenever --update-crontab limitos --set environment=production --roles=app,web,db`


### Auto-Update Functionality
<b>Raspberry Pi Clients:</b> Every 1 hour, the LimitOS Node.js script will automatically attempt to update to the latest version.  Please be aware that by installing LimitOS on your Raspberry Pi you are explicity agreeing to this functionality.

<b>Self-Hosted Servers:</b> Every 5 minutes, the LimitOS application will automatically attempt to update to the latest "master" branch version on GitHub at https://github.com/llawlor/LimitOS .  Please be aware that by running an installation of LimitOS you are explicity agreeing to this functionality.
