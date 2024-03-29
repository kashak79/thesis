require 'resque/tasks'

namespace :resque do
  desc 'Start the BJ software with one worker'
  task :start do
    sh %{resque-web -p 8080 > /dev/null 2>&1 &}
  end

  task :workers do
    3.times do
      sh %{QUEUE=* rake resque:work &}
    end
  end

  desc 'Stop the BJ software'
  task :stop do
    sh %{pkill ruby}
  end

  # include environment on process startup
  task :setup => :environment
end
