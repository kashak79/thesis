class Pipes::PublicationTitlePosTagging < Pipes::Pipe

  def initialize(tagger)
		@tagger = tagger
    super()
	end

  def execute
		publication = _in.get[:publication]
		nps = @tagger.get_noun_phrases(@tagger.add_tags(publication[:title]))
		publication[:nps] = nps
		enrich(:in, :out, :publication => publication)
  end
end