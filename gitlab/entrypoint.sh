#!/bin/bash

# Dynamically set the external_url to match the Ingress path
GITLAB_EXTERNAL_URL="http://$(hostname -i)"
echo $GITLAB_EXTERNAL_URL
echo "starting current version"

mkdir -p /config/gitlab
mkdir -p /data/gitlab


find /var/opt/gitlab -maxdepth 1 -type d | tail -n +2 > /data/gitlab/list.txt
for p in (/data/gitlab/list.txt)
do
    echo "${p}"
    folder=`echo "${p}" | rev | cut -d'/' -f1 | rev`
    echo "${folder}"
    rm -rf "${p}"
    ln -s "/data/gitlab/${p}" "${p}"
done

FILE=/config/gitlab/gitlab.rb
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else 
    echo "$FILE does not exist."
    cp /opt/gitlab/etc/gitlab.rb.template /config/gitlab/gitlab.rb

    rm /etc/gitlab/gitlab.rb

    ln -s /config/gitlab/gitlab.rb /etc/gitlab/gitlab.rb

    echo "external_url '${GITLAB_EXTERNAL_URL}'" >> /etc/gitlab/gitlab.rb
    echo "nginx['listen_port'] = 80;" >> /etc/gitlab/gitlab.rb
    echo "nginx['listen_https'] = false;" >> /etc/gitlab/gitlab.rb
    echo "gitlab_rails['trusted_proxies'] = ['172.30.32.2']" >> /etc/gitlab/gitlab.rb
    echo "gitlab_rails['initial_root_password'] = '<my_strong_password>'" >> /etc/gitlab/gitlab.rb
#    echo 'git_data_dirs({ "default" => { "path" => "/data/gitlab/git-data" } })' >> /etc/gitlab/gitlab.rb

fi

rm /etc/gitlab/gitlab.rb

ln -s /config/gitlab/gitlab.rb /etc/gitlab/gitlab.rb


#echo 'git_data_dirs({ "default" => { "path" => "/data/gitlab/git-data" } })' >> /etc/gitlab/gitlab.rb

# Reconfigure GitLab to apply changes
#gitlab-ctl reconfigure

/assets/wrapper
# Execute the Docker CMD
#exec "$@"
