#!/bin/sh
/bin/01_user_config.sh
/bin/02_auto_update.sh
/bin/03_set_a2port.sh
 
/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

