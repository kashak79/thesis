class Pipes::KeywordsRule < Pipes::Pipe

  def initialize(graph)
    super()
    @graph = graph
    @b = Helpers::QueryBuilder.new
  end

  def execute
    instance = _in.get[:instance]
    query = @b.v.out('"email"').in('"email"').except('[v]')
    email_instances = @graph.query(instance[:_id], query)
    email_instances.each do |email_instance|
			p "found email equality between #{instance[:_id]} and #{email_instance[:_id]}" if Configuration::DEBUG
      out.push(:similarity => {:from => instance[:_id], :to => email_instance[:_id], :weight => Configuration::EMAIL_WEIGHT, :type => "email equality"})
    end if email_instances # filter
  end
end
