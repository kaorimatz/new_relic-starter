FROM ruby:2.4-slim as builder

RUN apt-get update && apt-get -y install build-essential git

WORKDIR app
COPY . .
RUN bundle install
RUN bundle exec rake build


FROM ruby:2.4-slim

RUN apt-get update && apt-get -y install build-essential

WORKDIR app
COPY example .
COPY --from=builder /app/pkg .
RUN gem install -N new_relic-starter resqued unicorn
