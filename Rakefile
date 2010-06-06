require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |t|
  t.warning = false
  t.rcov = false
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => :spec

desc "Run the game"
task :run do
  exec('ruby lib/run.rb')
end
