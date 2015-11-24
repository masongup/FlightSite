require 'rake/testtask'

task default: [:test]

desc 'Runs unit tests'

task :test do
  Rake::TestTask.new do |t|
    t.pattern = '*_test.rb'
  end
end
