FROM node:20.19-alpine AS node
FROM ruby:3.4.4-alpine3.20
LABEL Organisation="Ministry of Justice"
LABEL Team="LAA Access Court Data"
LABEL Contact="<access-court-data-team@digital.justice.gov.uk>"

# fail early and print all commands
RUN set -ex

# Get node 20.19 from the node image into the ruby image
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# build dependencies:
# --virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
# - yarn for js dependency management
# - git for installing gems referred to using git:// uri

#
# runtime dependencies:
# - nodejs: for ExecJS and asset compilation
# - libxml2-dev/libxslt-dev for nokogiri, at least
# - postgres-dev for pg/activerecord gems
# - tzdata - for railtie/tzinfo-data ??
# - runit for process management (because we have multiple services)
#
RUN apk --update-cache upgrade \
&& apk --no-cache add --upgrade --virtual build-dependencies \
                    build-base \
                    yarn \
                    git \
&& apk --no-cache add --upgrade \
                  nodejs \
                  linux-headers \
                  libxml2-dev \
                  libxslt-dev \
                  postgresql-dev \
                  tzdata \
                  runit \
                  yaml-dev

# add non-root user and group with alpine first available uid, 1000
RUN addgroup -g 1000 -S appgroup \
&& adduser -u 1000 -S appuser -G appgroup

# create app directory in conventional, existing dir /usr/src
# tmp/pids/ needed for puma
RUN mkdir -p /usr/src/app \
&& mkdir -p /usr/src/app/tmp \
&& mkdir -p /usr/src/app/tmp/pids
WORKDIR /usr/src/app

######################
# DEPENDENCIES START #
######################
# => Ruby dependencies
COPY Gemfile* ./

# Installs bundler version used in Gemfile.lock
# - only install production dependencies
#
RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") \
&& bundle config --local without test development \
&& bundle config build.nokogiri --use-system-libraries \
&& bundle check || bundle install --jobs=4 --retry=3

####################
# DEPENDENCIES END #
####################
COPY . .

# precompile assets, silently (as verbose)
# note: webpacker:compile appended to the assets:precompile task
RUN SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here \
RAILS_ENV=production \
yarn install && yarn build 2> /dev/null
RUN SECRET_KEY_BASE=a-real-secret-key-is-not-needed-here \
RAILS_ENV=production \
bundle exec rails assets:precompile


# tidy up installation
RUN apk update && apk del build-dependencies

# non-root/appuser should own only what they need to
RUN chown -R appuser:appgroup log tmp db

# expect ping environment variables
ARG COMMIT_ID
ARG BUILD_DATE
ARG BUILD_TAG
ARG APP_BRANCH
ENV COMMIT_ID=${COMMIT_ID}
ENV BUILD_DATE=${BUILD_DATE}
ENV BUILD_TAG=${BUILD_TAG}
ENV APP_BRANCH=${APP_BRANCH}

USER 1000
CMD "./docker/docker-entrypoint.sh"
