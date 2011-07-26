require 'spec_helper'

describe Pipes::Dependency do
  let(:graph) { Helpers::Rexster.new('http://192.168.179.128:8182/testgraph')}
  let(:sink) { mock('sink').as_null_object }
  let(:redis) { mock('redis') }

  before(:each) do
    graph.clear
    graph.create_index(:family)
    graph.create_index(:name)

    $redis.flushdb
    sink.stub(:push) { |d| @data = d}
    @pipe = (Connections::Local).connection
    # test the integration pipe by binding it to a sink
    dependency = Pipes::Dependency.pipe
    @pipe.to(dependency, :store).out.connect.to(Pipes::Split.pipe(2)) do |split|
      split.out(1).connect(sink)
      split.out(2).connect.to(dependency, :resolve)
    end
  end

  it "should store a flow with dependencies" do
    @pipe.push(:name => 'Mattias', :dependencies => [1,2])
    $redis.llen("dep:#{1}").should == 1
    @pipe.push(:reference => 1)
    $redis.llen("dep:#{1}").should == 0
    $redis.llen("dep:#{2}").should == 1
    @pipe.push(:reference => 2)
    $redis.llen("dep:#{2}").should == 0
    # last flow is dependent flow
    @data[:name].should == 'Mattias'
  end

end
