module Pipes
  autoload :Pipe,                  'audisa/pipes/pipe'
  autoload :UniqueDiscovery,       'audisa/pipes/unique_discovery'
  autoload :Network,               'audisa/pipes/network'
  autoload :Persist,               'audisa/pipes/persist'
  autoload :Stdout,                'audisa/pipes/stdout'
  autoload :Filter,                'audisa/pipes/filter'
  autoload :Split,                 'audisa/pipes/split'
  autoload :Merge,                 'audisa/pipes/merge'
  autoload :Dependency,            'audisa/pipes/dependency'

  # integration pipes
  autoload :Integration,           'audisa/pipes/integration/integration'
  autoload :NameMatching,          'audisa/pipes/integration/name_matching'
  autoload :PersistFamily,         'audisa/pipes/integration/persist_family'
  autoload :PersistInstance,       'audisa/pipes/integration/persist_instance'
  autoload :PersistName,           'audisa/pipes/integration/persist_name'
	autoload :PublicationSearch,		 'audisa/pipes/integration/publication_search'
	autoload :PublicationText,			 'audisa/pipes/integration/publication_text'
	autoload :AuthorSearch,					 'audisa/pipes/integration/author_search'
	autoload :AbstractSearch, 			 'audisa/pipes/integration/abstract_search'
	autoload :PublicationTitlePosTagging,	'audisa/pipes/integration/publication_title_pos_tagging'
	autoload :PublicationAbstractPosTagging,	'audisa/pipes/integration/publication_abstract_pos_tagging'
	autoload :TagsToCategory, 			 'audisa/pipes/integration/tags_to_category'

	# clustering
	autoload :PersistSimilarity,      'audisa/pipes/clustering/persist_similarity'

  autoload :PersistDiscovery,      'audisa/pipes/persist_discovery'
  autoload :PersistFact,           'audisa/pipes/persist_fact'

  # rules
  autoload :CoAuthorRule,          'audisa/pipes/rules/co_author_rule.rb'
end
