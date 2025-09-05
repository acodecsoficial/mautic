#!/bin/sh
# Carrega variáveis de ambiente para o cron
env >> /etc/environment

if [ -f /etc/cron.d/mautic ]; then
  mv /etc/cron.d/mautic /etc/cron.d/mautic.old
fi

# Instala os crons
(crontab -l 2>/dev/null; \
echo "*/5 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:segments:update --batch-limit=1000" ; \
echo "* * * * * /usr/local/bin/php /var/www/html/bin/console mautic:campaigns:update --batch-limit=1000" ; \
echo "* * * * * /usr/local/bin/php /var/www/html/bin/console mautic:campaigns:trigger --batch-limit=" ; \
echo "* * * * * /usr/local/bin/php /var/www/html/bin/console mautic:emails:send" ; \
echo "0 3 * * * /usr/local/bin/php /var/www/html/bin/console mautic:contact:deduplicate" ; \
echo "*/5 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:import" ; \
echo "5,20,35,50 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:campaigns:rebuild" ; \
echo "45 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:messages:send" ; \
echo "0,15,30,45 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:email:fetch" ; \
echo "45 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:social:monitoring" ; \
echo "0,15,30,45 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:webhooks:process" ; \
echo "0,15,30,45 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:broadcasts:send" ; \
echo "* 1 * * * /usr/local/bin/php /var/www/html/bin/console mautic:maintenance:cleanup --days-old=3651" ; \
echo "0 4 15 * * /usr/local/bin/php /var/www/html/bin/console mautic:iplookup:download" ; \
echo "*/5 * * * * /usr/local/bin/php /var/www/html/bin/console mautic:reports:scheduler" ; \
echo "0 5 10 * * /usr/local/bin/php /var/www/html/bin/console mautic:unusedip:delete1" ; \
echo "@reboot [[ \"\$(ls -A /var/www/html/bin/cache/ip_data 2>/dev/null)\" ]] || /usr/local/bin/php /var/www/html/bin/console mautic:iplookup:download >> /root/mautic_iplookup_reboot.log 2>&1" \
) | crontab -

# Inicia o cron em foreground e depois a API ou outro processo, se desejar
exec cron -f -L 8
