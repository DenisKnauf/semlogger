require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "slogger"
    gem.summary = %Q{(Semi-)Structured Logger}
    gem.description = %Q{(Semi-)Structured Logger for Ruby (and Rails)}
    gem.email = %w[Denis.Knauf@gmail.com]
    gem.homepage = "http://github.com/DenisKnauf/Slogger"
    gem.authors = ["Denis Knauf"]
    gem.files = %w[AUTHORS README.md VERSION LICENSE lib/**/*.rb]
    gem.require_paths = %w[lib]
		gem.add_dependency 'json'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

#require 'rake/testtask'
#Rake::TestTask.new(:test) do |test|
  #test.libs << 'lib' << 'test'
  #test.pattern = 'test/**/*_test.rb'
  #test.verbose = true
#end

#begin
  #require 'rcov/rcovtask'
  #Rcov::RcovTask.new do |test|
    #test.libs << 'test'
    #test.pattern = 'test/**/*_test.rb'
    #test.verbose = true
  #end
#rescue LoadError
  #task :rcov do
    #abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  #end
#end

#task :test => :check_dependencies

#task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist? 'VERSION'
    version = File.read 'VERSION'
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Slogger #{version}"
  rdoc.rdoc_files.include 'README.md'
  rdoc.rdoc_files.include 'AUTHORS'
  rdoc.rdoc_files.include 'LICENSE'
  rdoc.rdoc_files.include 'lib/**/*.rb'
end
