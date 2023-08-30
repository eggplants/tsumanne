# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-sorbet'
end

namespace :sorbet do
  desc 'Type-checking with sorbet'
  task :check do
    system("bundle exec srb tc -v")
  end

  desc 'Type-checking and auto-fix correctable errors with sorbet'
  task :autocorrect do
    system("bundle exec srb tc --autocorrect -v")
  end
end

namespace :tapioca do
  desc 'Generate RBI from gems with tapioca'
  task :gen do
    system("bundle exec tapioca gem --all")
  end

  desc 'Check duplicated definitions exists in shim RBIs with tapioca'
  task :check_shims do
    system("bundle exec tapioca check-shims")
  end
end

task :default do
   %i[spec rubocop:autocorrect_all sorbet:autocorrect tapioca:check_shims].each do
     puts ".｡*ﾟ+.*.｡　　#{?\s * _1.size}　　ﾟ+..｡*ﾟ+"
     puts ".｡*ﾟ+.*.｡　　#{_1}　　ﾟ+..｡*ﾟ+"
     puts ".｡*ﾟ+.*.｡　　#{?\s * _1.size}　　ﾟ+..｡*ﾟ+"
     Rake::Task[_1].execute
   end
end
