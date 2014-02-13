require "bundler/gem_tasks"
require "superbolt/tasks"


# This one is for locally testing your crazy ideas
task :environment do
  class MySleeperCell < Superbolt::MessageHandler
    def perform
      sleep(rand(10))
    end
  end

  Superbolt.config = {
    connection_params: {
      host: '127.0.0.1',
      heartbeat: 1,
    }
  }
  Superbolt.app_name = 'food'
  Superbolt::Router.routes = {
    'do-it' => 'MySleeperCell'
  }
end
