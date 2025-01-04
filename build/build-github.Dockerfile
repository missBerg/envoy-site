FROM --platform=linux/amd64 envoy-site-base:latest

COPY --chown=builder:builder . /home/builder/app

WORKDIR /home/builder/app

RUN mkdir -p $BUILDER_HOME/generated && chown builder:builder $BUILDER_HOME/generated

RUN chmod +x /home/builder/app/build_site.sh

ENTRYPOINT ["/home/builder/app/build_site.sh"]
