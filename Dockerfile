FROM ubuntu:14.04

RUN apt-get update && \
    apt-get -y upgrade

RUN useradd forge
RUN mkdir -p /opt/forge/log && \
    mkdir -p /opt/forge/cache && \
    mkdir -p /opt/forge/modules && \
    chown -R forge /opt/forge

ENV FORGE_S3BUCKET='##AWS_BUCKET##'
ENV FORGE_AWS_SECRET='##AWS_SECRET_ACCESS_KEY##'
ENV FORGE_AWS_KEY='##AWS_ACCESS_KEY_ID##'
ENV FORGE_PORT=8080
ENV FORGE_LOGDIR=/opt/forge/log
ENV FORGE_CACHEDIR=/opt/forge/cache
ENV FORGE_PROXY='https://forgeapi.puppetlabs.com'
ENV FORGE_PIDFILE='/opt/forge/server.pid'
ENV FORGE_AWS_REGION='##AWS_REGION##'

RUN apt-get -y install ruby ruby-dev build-essential
RUN gem install aws-sdk

COPY puppet-forge-server-*.gem /
COPY Gemfile-dockerfile /Gemfile
RUN gem install bundle
RUN bundle install --gemfile=/Gemfile
RUN gem install --local /puppet-forge-server-*.gem

USER forge
ENTRYPOINT [ "puppet-forge-server" ]
