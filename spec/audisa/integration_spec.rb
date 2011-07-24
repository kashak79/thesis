require 'spec_helper'

describe Pipes::Integration do
  let(:graph) { Helpers::Rexster.new('http://192.168.179.128:8182/testgraph')}
  let(:sink) { mock('sink').as_null_object }

  before(:each) do
    graph.clear
    graph.create_index(:family)
    graph.create_index(:name)

    sink.stub(:push) { |d| @data = d}
    @pipe = (Connections::Local).connection
    # test the integration pipe by binding it to a sink
    @pipe.to(Pipes::Integration.pipe(graph)).out.connect(sink)
  end

  it 'should add instance and author' do
    @pipe.push(:instance => {:name => 'Mattias A. Putman'})
    @data.should satisfy { |d| d[:instance][:_id] && d[:author][:_id] }
    # check graph state
    # there should be an instance_of edge between instance and author
    graph.out(:instance_of, @data[:instance][:_id])[0][:_inV].should == @data[:author][:_id]
  end

  it 'should add the family/couple to the family' do
    @pipe.push(:instance => {:name => 'Mattias A. Putman'})
    # now @date is the previous push
    family_id = @data[:family][:_id]

    @pipe.push(:instance => {:name => 'Ruben Putman'})
    @data[:family][:_id].should == family_id
    family_id = @data[:family][:_id]

    # adding simon buelens should make a new family
    @pipe.push(:instance => {:name => 'Simon P. Buelens'})
    @data[:family][:_id].should_not == family_id

    # there should be an author_of edge between author and family
    graph.out(:author_of, @data[:author][:_id])[0][:_inV].should == @data[:family][:_id]
  end

  it 'should add the name/couple to the name' do
    @pipe.push(:instance => {:name => 'Mattias A. Putman'})
    @data.should satisfy { |d| d[:name][:_id] }
    name_id = @data[:name][:_id]

    @pipe.push(:instance => {:name => 'Mattias A. Putman'})
    @data[:name][:_id].should == name_id

    # there should be a name edge between instance and name
    # there should be a family edge between name and family
    graph.out(:name, @data[:instance][:_id])[0][:_inV].should == @data[:name][:_id]
    graph.out(:family, @data[:name][:_id])[0][:_inV].should == @data[:family][:_id]
  end

  it 'should match a name with the right names' do
    @pipe.push(:instance => {:name => 'Mattias A. Putman'})
    name1 = @data[:name][:_id]
    @pipe.push(:instance => {:name => 'M. A. Putman'})
    name2 = @data[:name][:_id]
    # there should be a match edge between those 2 names
    graph.both(:matches, name1)[0][:_outV].should == name2
  end
end
