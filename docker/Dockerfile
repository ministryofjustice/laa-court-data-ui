FROM node:20.20-alpine3.23 AS node
FROM ruby:3.4.12-alpine3.23
LABEL Organisation="Ministry of Justice"
LABEL Team="LAA Access Court Data"
LABEL Contact="<access-court-data-team@digital.justice.gov.uk>"

# fail early and print all commands
RUN set -ex

# Copy only Node and Yarn; keep Alpine's system libraries from the Ruby image.
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-v* /opt/yarn
RUN ln -s /opt/yarn/bin/yarn /usr/local/bin/yarn \
&& ln -s /opt/yarn/bin/yarnpkg /usr/local/bin/yarnpkg

# build dependencies:
# --virtual: create virtual package for later deletion
# - build-base for alpine fundamentals
# - git for installing gems referred to using git:// uri

#
# runtime dependencies:
# - libstdc++: runtime libraries for the copied Node binary
# - libxml2-dev/libxslt-dev for nokogiri, at least
# - postgres-dev for pg/activerecord gems
# - tzdata - for railtie/tzinfo-data ??
# - runit for process management (because we have multiple services)
#
RUN apk --update-cache upgrade \
&& apk --no-cache add --upgrade --virtual build-dependencies \
                    build-base \
                    git \
&& apk --no-cache add --upgrade \
                  libstdc++ \
                  linux-headers \
                  libxml2-dev \
                  libxslt-dev \
                  postgresql-dev \
                  tzdata \
                  runit \
                  yaml-dev \
                  $(if [ "$BUNDLE_DEPLOYMENT" == "false" ]; then echo "libffi-dev"; fi)

# Force upgrade of CA trust-store certs
RUN apk add --no-cache --upgrade \
    ca-certificates \
    ca-certificates-bundle

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
# - install production dependencies unless building a development image
#
RUN gem install bundler -v $(cat Gemfile.lock | tail -1 | tr -d " ") \
&& if [ "$BUNDLE_DEPLOYMENT" != "false" ]; then bundle config --local without test development; fi \
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
