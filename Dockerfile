FROM ruby:2.1.5-onbuild

CMD bash -c 'env && exec bundle exec foreman run rackup -p $PORT'
