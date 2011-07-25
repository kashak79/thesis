class Pipes::Integration < Pipes::Pipe

  # define the composite pipe
  def initialize(graph)
    super()
    @persist_instance = Pipes::PersistInstance.pipe(graph)

    family_merge = Pipes::Merge.pipe(2)

    @persist_instance.out.connect.to(Pipes::PersistFamily.pipe(graph)) do |persist_family|
      persist_family.out(:new).connect.to(family_merge, 1)
      persist_family.out(:exist).connect.to(family_merge, 2)
    end

    @merge = Pipes::Merge.pipe(2)

    family_merge.out.connect.to(Pipes::PersistName.pipe(graph)) do |persist_name|
      persist_name.out(:new).connect.to(Pipes::NameMatching.pipe(graph, Helpers::Dtw.new, 0.1)).
        out.connect.to(@merge, 1)
      persist_name.out(:exist).connect.to(@merge, 2)
    end
  end

  # define composite pipe ins
  def in(name = :in)
    @persist_instance.in(name)
  end

  # define composite pipe outs
  def out(name = :out)
    @merge.out(name)
  end

end
