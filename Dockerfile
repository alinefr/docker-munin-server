#------------------------------------------------------------------------
# Munin Server using nginx + fastcgi
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/
#------------------------------------------------------------------------
#
# AUTHOR: jd@lps.rocks
# WEBSITE: github.com/lps-rocks/docker-munin-server

# Base Image
ARG ARCH=amd64
FROM alpine
ARG ARCH

# Update existing packages
RUN apk upgrade --no-cache

# Install APK Packages 
RUN apk add --no-cache jq curl nginx munin spawn-fcgi perl-cgi-fast logrotate ttf-dejavu openssl bash ca-certificates msmtp

# Set shell to bash
RUN sed -e 's;/bin/ash$;/bin/bash;g' -i /etc/passwd

# Download latest S3 overlay version
RUN set -x && curl -Ls $(curl -s https://api.github.com/repos/just-containers/s6-overlay/releases/latest \ 
	| jq -r --arg arch ${ARCH} '.assets[] | select(.name=="s6-overlay-"+ $arch + ".tar.gz") | .browser_download_url') \ 
	> /tmp/s6-overlay.tar.gz

# Extract the S6 overlay
RUN tar xvzf /tmp/s6-overlay.tar.gz -C / && rm /tmp/s6-overlay.tar.gz

# Modify Munin configuration file
RUN sed -i -e '/^[^#]/ s/^.*$/#\0/' -e 's/#graph_strategy cron/graph_strategy cgi/' \
	-e 's/#html_strategy cron/html_strategy cgi/' \
	-e 's/#cgiurl_graph \/munin-cgi\/munin-cgi-graph/cgiurl_graph \/munin-cgi\/munin-cgi-graph/' \
	-e 's/#includedir \/etc\/munin\/munin-conf.d/includedir \/etc\/munin\/munin-conf.d/' \
	/etc/munin/munin.conf

# Copy additional files
ADD rootfs/ /

# Ports
EXPOSE 80

# Volumes
VOLUME /var/lib/munin
VOLUME /var/log/munin
VOLUME /var/cache/munin

ENTRYPOINT ["/init"]
