class Pipes::TagsToCategory < Pipes::Pipe

  def initialize(categories)
		@categories = categories
    super()
	end

  def execute
		publication = _in.get[:publication]
		nps = publication[:nps].map { |h,l| Hash[h, Hash[:count, l, :in_categories, @categories.index(h.downcase) != nil]] }
		publication[:nps] = nps
		enrich(:in, :out, :publication => publication)
  end
end