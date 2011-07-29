namespace :whitespace do
  desc 'Removes trailing whitespace'
  task :cleanup do
    sh %{for f in `find truth lib spec testpipe.rb config -type f | grep -v -e '.git/' -e 'public/' -e '.png'`;
          do cat $f | sed 's/[ \t]*[\r]*$//' > tmp; cp tmp $f; rm tmp; echo -n .;
        done}
  end

  desc 'Converts hard-tabs into two-space soft-tabs'
  task :retab do
    sh %{for f in `find lib -type f | grep -v -e '.git/' -e 'public/' -e '.png'`;
          do cat $f | sed 's/\t/  /g' > tmp; cp tmp $f; rm tmp; echo -n .;
        done}
  end
end
