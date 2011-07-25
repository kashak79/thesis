class Pipes::Dependency < Pipes::Pipe

  def initialize
    super([:store,:resolve], [:out])
  end

  def execute
    (touched == _in(:store)) ? store(_in(:store).get) : resolve(_in(:resolve).get)
  end

  # need redis watch here
  def store(flow)
    #p flow
    # get the dependencies of this flow
    dependencies = flow[:dependencies] || []
    # try to resolve as many dependencies as possible
    found = []
    dependencies.each do |dep|
      ref_flow = Yajl::Parser.parse($redis.get("flow:#{dep}") || "")
      if ref_flow
        #puts "found dependency"
        #puts "dep: #{ref_flow}"
        #puts "for: #{flow}"
        #puts "-----------------------------------"
        found << dep
        flow.merge!(ref_flow.symbolize!)
      end
    end
    flow[:dependencies] = dependencies = dependencies - found
    # if there are any dependencies left
    # we must wait for other dependencies
    # so store (and do not push)
    # otherwise push
    if dependencies.empty?
      #puts "released #{flow}"
      out.push(flow)
    else
      dep = dependencies.first
      dependencies.delete(dep)
      #puts "stored #{flow}"
      $redis.rpush("dep:#{dep}", Yajl::Encoder.encode(flow))
    end
  end

  # can be implemented more efficiently
  def resolve(flow)
    # resolve all dependencies
    reference = flow[:reference]
    #puts "stored ref #{flow}"
    $redis.setex("flow:#{reference}", 60, Yajl::Encoder.encode(flow))
    while dep_flow = Yajl::Parser.parse($redis.lpop("dep:#{reference}") || "") do
      store(dep_flow.symbolize!)
    end
  end

end