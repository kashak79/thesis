class Pipes::PublicationAbstractPosTagging < Pipes::Pipe

  def initialize(tagger)
		@tagger = tagger
    super()
	end

  def execute
		publication = _in.get[:publication]
		nps = @tagger.get_noun_phrases(@tagger.add_tags(publication[:abstract]))
		publication[:nps_abstract] = nps
		enrich(:in, :out, :publication => publication)
  end
end