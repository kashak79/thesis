require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new { |t|
  t.rspec_opts = '--color --format doc'
}
