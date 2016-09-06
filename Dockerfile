FROM rancher/confd-base:0.11.0-dev-rancher
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*
ADD ./conf.d /etc/confd/conf.d
ADD ./templates /etc/confd/templates
VOLUME /etc/nginx/conf.d
ENTRYPOINT ["/confd"]

CMD ["--backend", "rancher", "--prefix", "/2015-07-25", "--log-level", "debug"]
