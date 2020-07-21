#!/usr/bin/env ruby
# creates a new release and tag
# In order to bundle and execute: ruby script/release.rb
require 'bundler/inline'
require 'colorize'

gemfile do
  source 'https://rubygems.org'
  gem 'tty-prompt'
  gem 'chris_lib', require: 'chris_lib/shell_methods'
end
include ShellMethods

prompt = TTY::Prompt.new
name = prompt.select 'Select pdf file name:', %w(fii systems)
copy_file_from_repo name
target = prompt.ask 'Enter target name (copy from \fancyhead minus pdf extension):'
system("mv #{name}.pdf #{target}.pdf" )
git_commit "add #{target}.pdf"
system('git push origin master')
system("open #{target}.pdf")
yes = prompt.yes? "Does url in header of pdf got to latest release?"
puts "You need to fix url".colorize(:red)
exit unless yes
tag = prompt.ask 'Tag name, as shown in \fancyhead:'
system("git tag -a #{tag} -m 'New release'")
system("git push origin #{tag}")
puts 'All Done'.colorize(:green)

BEGIN {
  def git_commit(msg)
    `git add .`
    `git status`
    system("git commit -m '#{msg}'")
  end

  def copy_file_from_repo(name)
    case name
    when 'fii'
      system('cp ../covid_tracker/latex/free_infected/fii.pdf fii.pdf')
    when 'systems'
      system('cp ../covid_tracker/latex/self_isolation/systems.pdf systems.pdf')
    else
      puts "Need to add provision for #{name} in case statement".colorize(:red)
      exit
    end
  end
}

