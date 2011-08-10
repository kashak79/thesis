
$config = :basic

if $config == :lowkey
  module Configuration
  
    ALPHA = 25
    AFFILIATION_WEIGHT = 10
    AFFILIATION_THRESHOLD = 0.8
    EMAIL_WEIGHT = 1000
    KEYWORD_WEIGHT = 1
    COAUTHOR_EQNAME_WEIGHT = 8
    COAUTHOR_MATCHINGNAME_WEIGHT = 6
    DEBUG = true
    
    CASE3_SPECIAL = ALPHA/2
    
  end
elsif $config == :basic
  module Configuration
  
    ALPHA = 5
    AFFILIATION_WEIGHT = 10
    AFFILIATION_THRESHOLD = 0.8
    EMAIL_WEIGHT = 1000
    KEYWORD_WEIGHT = 4
    COAUTHOR_EQNAME_WEIGHT = 8
    COAUTHOR_MATCHINGNAME_WEIGHT = 6
    DEBUG = true
    
    CASE3_SPECIAL = ALPHA/2
    
  end
end