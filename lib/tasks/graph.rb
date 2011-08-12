require 'yajl'
require 'typhoeus'
require 'audisa/helpers'

# tijdelijk
# hash symbolize
class Hash
  def symbolize!
    adding = Hash.new
    self.each do |k,v|
      adding[k.to_sym] = v
      self.delete(k)
    end
    adding.each do |k,v|
      self[k] = if v.kind_of?(Hash)
        v.symbolize!
      elsif v.kind_of?(Array)
        v.map { |h| h.kind_of?(Hash) ? h.symbolize! : h }
      else
        v
      end
    end
  end

  def reject_keys(*keys)
    reject { |k,v| keys.include? k }
  end
end

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
	
	task :export, [:name, :db, :file] do |t, args|
		graph = Helpers::Rexster.new('http://192.168.179.128:8182/thesis')
		id = graph.index("family",args[:name]).first[:_id]
		clusters = graph.table(id, Helpers::QueryBuilder.new.v.in('"author_of"').as('"\'cluster\'"').in('"instance_of"').as('"\'name\'"').out('"published"').as('"\'publication\'"').table(:id, :name, :title))
		Yajl::Encoder.new.encode(clusters, File.new(args[:file],'wb'))
	end

  task :reload => [:stop, :extensions, :start]
end
