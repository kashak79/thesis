require 'cgi'

class Helpers::Rexster

  def initialize(base)
    @base = base
  end

  def escape(value)
    CGI::escape(value)
  end

  def request(method, url = '', options = {})
    response = Typhoeus::Request.send(method, @base + url, options)
    result = Yajl::Parser.parse(response.body)["results"]
    if result && result.kind_of?(Array)
      result.map { |h| h.kind_of?(Hash) ? h.symbolize! : h }
    elsif result
      result.symbolize!
    end
  end

  # remove everything from the graph
  def clear
    request(:delete)
  end

  # create a new index
  def create_index(index)
    request(:post, "/indices/#{index}", :params => {:class => 'vertex', :type => 'manual'})
  end

  # get the value of an index
  def index(index, value)
    request(:get, "/indices/#{index}", :params => {:key => index, :value => escape(value)})
  end

  # put something new in an index
  def put_index(index, value, id)
    request(:post, "/indices/#{index}", :params => {
      :key => index, :value => escape(value), :id => id, :class => 'vertex'})
  end

  # create a new vertex with properties
  def create_vertex(properties)
    request(:post, '/vertices', :params => properties)
  end

  # create a new edge with properties
  def create_edge(label, from, to)
    request(:post, '/edges', :params => {:_outV => from, :_inV => to, :_label => label})
  end

  def delete_edge(id)
    request(:delete, "/edges/#{id}")
  end

  def update_edge(id, properties)
    request(:post, "/edges/#{id}", :params => properties)
  end

  # query out edges
  def out(label, from)
    request(:get, "/vertices/#{from}/outE", :params => {:_label => label})
  end

  def in(label, from)
    request(:get, "/vertices/#{from}/inE", :params => {:_label => label})
  end

  # query both edges
  def both(label, from)
    request(:get, "/vertices/#{from}/bothE", :params => {:_label => label})
  end

  def delete_vertex(id)
    request(:delete, "/vertices/#{id}")
  end

  # perform a query on a vertex
  def query(vertex, query)
    request(:get, "/vertices/#{vertex}/tp/gremlin", :params => {:script => query})
  end

  def table(vertex, query)
    a = request(:get, "/vertices/#{vertex}/tp/gremlin", :params => {:script => query})
    # convert table string to ruby
		p a[0][1..-2]
    Yajl::Parser.parse("[#{a[0][1..-2].gsub(/affiliation':([^\]]*)/,"affiliation':'\\1'").gsub('[','{').gsub(']','}').gsub("'",'"')}]").map { |h|
      h.kind_of?(Hash) ? h.symbolize! : h
    } if a && a[0]
  end

end
