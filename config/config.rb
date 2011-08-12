
$config = :custom

if $config == :custom
  module Configuration
  
    ALPHA = 5
    AFFILIATION_WEIGHT = 50
    AFFILIATION_THRESHOLD = 0.6
    EMAIL_WEIGHT = 1000
    KEYWORD_WEIGHT = 0
    COAUTHOR_EQNAME_WEIGHT = 50
    COAUTHOR_MATCHINGNAME_WEIGHT = 30
    DEBUG = true
    
    COMMUNITY = true
    EMAIL = true
    AFFILIATION = true
    KEYWORD = false
    
    CASE3_SPECIAL = ALPHA/2
    
  end
elsif $config == :lowkey
  module Configuration
  
    ALPHA = 25
    AFFILIATION_WEIGHT = 10
    AFFILIATION_THRESHOLD = 0.8
    EMAIL_WEIGHT = 1000
    KEYWORD_WEIGHT = 1
    COAUTHOR_EQNAME_WEIGHT = 8
    COAUTHOR_MATCHINGNAME_WEIGHT = 6
    DEBUG = true
    
    COMMUNITY = true
    EMAIL = true
    AFFILIATION = true
    KEYWORD = true
    
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
    
    COMMUNITY = false
    EMAIL = true
    AFFILIATION = true
    KEYWORD = false
    
    CASE3_SPECIAL = ALPHA/2
    
  end
elsif $config == :highco
  module Configuration
  
    ALPHA = 25
    AFFILIATION_WEIGHT = 10
    AFFILIATION_THRESHOLD = 0.8
    EMAIL_WEIGHT = 1000
    KEYWORD_WEIGHT = 1
    COAUTHOR_EQNAME_WEIGHT = 50
    COAUTHOR_MATCHINGNAME_WEIGHT = 30
    DEBUG = true
    
    COMMUNITY = true
    EMAIL = true
    AFFILIATION = true
    KEYWORD = false
    
    CASE3_SPECIAL = ALPHA/2
    
  end
elsif $config == :highkey
  module Configuration
  
    ALPHA = 25
    AFFILIATION_WEIGHT = 10
    AFFILIATION_THRESHOLD = 0.8
    EMAIL_WEIGHT = 1000
    KEYWORD_WEIGHT = 10
    COAUTHOR_EQNAME_WEIGHT = 50
    COAUTHOR_MATCHINGNAME_WEIGHT = 30
    DEBUG = true
    
    COMMUNITY = false
    EMAIL = true
    AFFILIATION = true
    KEYWORD = true
    
    CASE3_SPECIAL = ALPHA/2
    
  end
elsif $config == :highcoaff
  module Configuration
  
    ALPHA = 25
    AFFILIATION_WEIGHT = 50
    AFFILIATION_THRESHOLD = 0.8
    EMAIL_WEIGHT = 1000
    KEYWORD_WEIGHT = 1
    COAUTHOR_EQNAME_WEIGHT = 50
    COAUTHOR_MATCHINGNAME_WEIGHT = 30
    DEBUG = true
    
    COMMUNITY = true
    EMAIL = true
    AFFILIATION = true
    KEYWORD = true
    
    CASE3_SPECIAL = ALPHA/2
    
  end
end