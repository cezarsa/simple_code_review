web: bundle exec thin start -p $PORT
resque: bundle exec rake resque:work
resqueweb: bundle exec resque-web --foreground --no-launch
scheduler: bundle exec rake resque:scheduler
