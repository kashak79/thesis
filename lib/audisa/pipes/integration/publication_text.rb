require 'docsplit'

class Pipes::PublicationText < Pipes::Pipe

  # mss meegeven in constructor ..
  DEFAULT_PATH = '/tmp/thesis-pdf'

  def initialize()
    super()
	end

  def execute
		#get the title of the paper
		p path = _in.get[:path] || DEFAULT_PATH+"/#{_in.get[:publication][:title].gsub(' ','-')}"
		Docsplit.extract_text(path, :pages => [1])
		# remove the pdf ?
		#`rm #{path}`
		enrich(:in, :out, :full => {:path => path })
  end

end
