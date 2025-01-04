FROM ericatetrate/envoy-site-base:latest

COPY --chown=builder:builder . /home/builder/app

WORKDIR /home/builder/app

RUN chmod +x serve_site.sh

ENTRYPOINT ["/home/builder/app/serve_site.sh"]
