class Pipes::AuthorSearch < Pipes::Pipe

  def initialize()
    super()
	end

  def execute
		author = _in.get[:author][:name].downcase
		pub = _in.get[:publication]
		if (!$redis.exists(pub)) then
			file = File.open(_in.get[:full][:path])
			content = file.read
			r = Regexp.new(/\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\b/)
			emails = content.scan(r).uniq
			$redis.set pub, 1
			emails.each { |e| $redis.sadd("#{pub}:emails", e) }
		else
			emails = $redis.smembers "#{pub}:emails"
		end
		email = emails.max_by do |email|
			e = email.split('@').first
			if (e.size < 4) then
				if (author.split.last.size < 4) then
					e.levenshtein_similar author.split.last
				else
					e.levenshtein_similar author.split.map { |a| a[0] }.join
				end
			else
				e.levenshtein_similar author
			end
		end
		$redis.srem("#{pub}:emails", email)
		enrich(:in, :out, :email => { :email => email })
  end
end