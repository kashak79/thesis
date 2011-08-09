class Helpers::AffiliationMatcher
  def match(sa, sb)

    a = sa.downcase.gsub(/[^a-zA-Z ]/,'').split.uniq
    b = sb.downcase.gsub(/[^a-zA-Z ]/,'').split.uniq
		
		length = [a.size, b.size].min

		equals = 0
		
		a.each do |word|
			equals += 1 if b.index(word)
		end
		
		return 1.0 * equals / length
  end

end
