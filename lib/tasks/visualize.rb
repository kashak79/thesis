def weights(pairs)
  $redis.mget(pairs.map { |pair|
    ["A:#{pair[0]}:#{pair[1]}", "A:#{pair[1]}:#{pair[0]}"] # both sides
  }.flatten)
end

task :A => :environment do |t,args|
  family_name = "Woo"
  graph = Helpers::Rexster.new('http://192.168.179.128:8182/thesis')
  builder = Helpers::QueryBuilder.new
  family_id = graph.index(:family, family_name).first[:_id]
  instance_ids = graph.query(family_id, builder.v.in('"author_of"').in('"instance_of"')).map { |inst|
    inst[:_id]
  }
  p instance_ids
  instance_ids.product(instance_ids).each do |id1,id2|
    ws = $redis.mget("A:#{id1}:#{id2}", "A:#{id2}:#{id1}")
    sum = (ws[0].to_i || 0) + (ws[1].to_i || 0)
    if sum > 0
      p graph.query(id1, builder.v.out('"published"'))
      pub1 = graph.query(id1, builder.v.out('"published"')).first[:title]
      pub2 = graph.query(id2, builder.v.out('"published"')).first[:title]
      p pub1
      p pub2
    end
  end
end
