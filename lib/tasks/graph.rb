namespace :graph do
  desc 'Start the graph software'
  task :start do
    sh %{sh vendor/rexster-0.4.1/target/rexster-0.4.1-standalone/bin/rexster-start.sh --configuration config/graph.xml > /dev/null &}
  end

  desc 'Stop the graph software'
  task :stop do
    sh %{vendor/rexster-0.4.1/target/rexster-0.4.1-standalone/bin/rexster-stop.sh > /dev/null 2>&1 &}
  end

  task :restart => [:stop, :start]

  task :setup do
    sh %{curl -X POST "http://192.168.179.128:8182/thesis/indices/name?class=vertex&type=manual"}
  end

  task :extensions do
    sh %{mvn -f rules/pom.xml install}
    sh %{cp rules/target/rules-1.0.jar vendor/rexster-0.4.1/target/rexster-0.4.1-standalone/ext}
  end

  task :reload => [:stop, :extensions, :start]
end
