# assumes an environment task that sets up your app environment
desc "worker that reads the queue and sends messages through the router as configured"
task :superbolt => :environment do
  Superbolt::App.new(Superbolt.app_name).run do |message, logger|
    Superbolt::Router.new(message, logger).perform
  end
end