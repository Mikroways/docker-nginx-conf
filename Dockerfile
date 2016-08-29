FROM nginx
MAINTAINER Geronimo Afonso "geronimo.afonso@mikroways.net"

RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*


COPY template-wordpress.conf /etc/nginx/conf.d/site-default
COPY locations.custom /etc/nginx/conf.d/
COPY fastcgi_params.custom /etc/nginx/conf.d/
COPY config.sh /
RUN chmod +x /config.sh
ENTRYPOINT ["/config.sh"]

CMD ["nginx","-g","daemon off;"]

