class Pipes::MagicFacts < Pipes::Pipe

  def initialize(graph, source)
    super()
    @graph = graph
    @locking = Helpers::Locker.new
    @facts = Yajl::Parser.parse(source)
  end

  def execute
    publication = _in.get[:publication]
		instance = _in.get[:instance]
		if @facts[instance[:name]].nil? || @facts[instance[:name]][publication[:title]].nil? then
			out.push(_in.get) 
			return
		end
		fact = @facts[instance[:name]][publication[:title]]
		# first lock to avoid creating 2 equal emails
    email = nil
		# Add affiliation as an attribute, not a vertex ?
		output = {}
		output[:email] = email if !email.nil? && !email.empty?
		output[:affiliation] = affiliation = @graph.create_vertex(:affiliation => fact["affiliation"]) if !fact["affiliation"].nil? && !fact["affiliation"].empty?
		p output if Configuration::DEBUG && !output.empty?
		# Enrich the output with this new information
		enrich(:in, :out, output) if !output.empty?
  end

end