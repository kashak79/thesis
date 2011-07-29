class Pipes::CoAuthorRule < Pipes::Pipe

  def initialize(graph)
    super()
    @graph = graph
    @b = Helpers::QueryBuilder.new
  end

  def execute
    instance = _in.get[:instance]
    # double name-equality query
    query = @b.v.name_inst.except('[v]').co_inst.as('"\'from\'"').name_inst.retain(
              @b.v.co_inst.except('[v]').to_a
            ).as('"\'to\'"').table(:id,:id)
    similarities = @graph.table(instance[:_id], query)
    similarities.each do |similarity|
      out.push(:similarity => similarity.merge({:weight => 1}))
    end if similarities # filter
  end

end
