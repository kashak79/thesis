class Pipes::MagicFacts < Pipes::Pipe

  def initialize(graph, source)
    super()
		puts "lalal"
    @graph = graph
    @locking = Helpers::Locker.new
    @facts = Yajl::Parser.parse(source)
  end

  def execute
    publication = _in.get[:publication]
		instance = _in.get[:instance]
		out.push(_in.get) if @facts[instance[:name]].nil? || @facts[instance[:name]][publication[:title]].nil?
		fact = @facts[instance[:name]][publication[:title]]
		# first lock to avoid creating 2 equal emails
    email = nil
    @locking.locked(fact["email"]) do
      # does the email exist?
      email = @graph.index(:email, fact["email"]).first
      if !email
        dyn_out = :new
        # create the email
        email = @graph.create_vertex(:email => fact["email"])
        # put in the index
        @graph.put_index(:email, fact["email"], email[:_id])
      end
    end if !fact["email"].nil?
		# Add affiliation as an attribute, not a vertex ?
		output = {}
		output[:email] = email if !email.nil?
		output[:affiliation] = affiliation = @graph.create_vertex(:affiliation => fact["affiliation"]) if !fact["affiliation"].nil?
		p output
		# Enrich the output with this new information
		enrich(:in, :out, output) if !output.empty?
  end

end