namespace :graph do
  desc 'Start the graph software'
  task :start do
    sh %{vendor/rexster-0.4.1/target/rexster-0.4.1-standalone/bin/rexter-start.sh > /dev/null}
  end

  desc 'Stop the graph software'
  task :stop do
    sh %{vendor/rexster-0.4.1/target/rexster-0.4.1-standalone/bin/rexter-stop.sh > /dev/null}
  end
end
