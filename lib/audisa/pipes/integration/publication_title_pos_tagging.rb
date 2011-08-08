class Pipes::PublicationTitlePosTagging < Pipes::Pipe

  def initialize(tagger)
		@tagger = tagger
    super()
	end

  def execute
		publication = _in.get[:publication]
		nps = _in.get[:keywords] || []
		nps << @tagger.get_noun_phrases(@tagger.add_tags(publication[:title])).map { |tag| {:keyword => tag[0]} }
		enrich(:in, :out, :keywords => nps.flatten)
  end
end