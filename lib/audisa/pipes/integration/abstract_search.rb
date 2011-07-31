class Pipes::AbstractSearch < Pipes::Pipe

  def initialize()
    super()
	end

  def execute
		pub = _in.get[:publication]
		file = File.open(_in.get[:full][:path], mode: 'r:BINARY')
		content = file.read
		r = Regexp.new(/[Aa][bB][Ss][Tt][Rr][Aa][Cc][Tt]\S*\n[^\n]+\n\n/)
		abstract = content.scan(r).first
		pub[:abstract] = abstract.sub(/[Aa][bB][Ss][Tt][Rr][Aa][Cc][Tt]\S*\n/,'').sub(/\n*$/,'')
		enrich(:in, :out, :publication => pub)
  end
end