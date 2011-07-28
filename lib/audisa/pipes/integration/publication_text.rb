require 'docsplit'

class Pipes::PublicationText < Pipes::Pipe

  def initialize()
    super()
	end

  def execute
		#get the title of the paper
		p path = _in.get[:full][:path]
		Docsplit.extract_text(path, :pages => [1])
		# remove the pdf ?
		#`rm #{path}`
		enrich(:in, :out, :full => {:path => path })
  end

end
