# assumes an environment task that sets up your app environment
desc "worker that reads the queue and sends messages through the router as configured"
task :superbolt => :environment do
  begin
    Superbolt::App.new(Superbolt.app_name, {}).run do |message, logger|
      Superbolt::Router.new(message, logger).perform
    end
  # Rescue SignalException so that we don't spam error handlers like Airbrake
  # with SIGTERM errors every time a task is killed (machine restarts, etc.)
  rescue SignalException => e
    Rails.logger.info(e.message)
  end
end
