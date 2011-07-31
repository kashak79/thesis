class Helpers::QueryBuilder

  class Query
    def initialize
      @query = nil
    end

    def append q
      @query ? @query = @query+".#{q}" : @query = q
      self
    end

    def v
      append 'v'
    end

    def name_inst
      append 'out("name").both("name")' # both????
    end

    def match_inst
      append 'out("name").both("matches").in("name")'
    end

    def co_inst
      append 'out("published").in("published")'
    end

    def to_a
      @query = @query + ">>(#{@query}.count().toInteger())"
    end

    def table(*clos)
      @query = "t=new Table();#{@query}.table(t)" + clos.map { |cl| "{it.#{cl.to_s}}"} * ''
      append 'cap'
    end

    def method_missing name, *args
      append "#{name}(#{args[0]})"
    end

    def to_s
      @query
    end
  end

  def v
    Query.new.v
  end

end
