# assumes an environment task that sets up your app environment
desc "worker that reads the queue and sends messages through the router as configured"
task :superbolt => :environment do
  statsd = defined?(::Statsd) ? ::Statsd.new("localhost", 8125) : nil
  begin
    Superbolt::App.new(Superbolt.app_name, {}).run do |message, logger|
      begin
        Superbolt::Router.new(message, logger).perform
        statsd.increment("app.#{Superbolt.app_name}.messages.#{message["event"]}.success") if statsd
      rescue => e
        statsd.increment("app.#{Superbolt.app_name}.messages.#{message["event"]}.error") if statsd
        raise e
      end
    end
  # Rescue SignalException so that we don't spam error handlers like Airbrake
  # with SIGTERM errors every time a task is killed (machine restarts, etc.)
  rescue SignalException => e
    Rails.logger.info(e.message)
  end
end
