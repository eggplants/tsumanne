# typed: ignore

# frozen_string_literal: true

require "English"

require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "rubocop/rake_task"
# require "sorbet-runtime"

# T.bind(self, T.all(Rake::DSL, Object))

RSpec::Core::RakeTask.new(:spec)

RuboCop::RakeTask.new do |task|
  task.requires << "rubocop-sorbet"
end

namespace :mdl do
  desc "Format markdown files with markdownlint"
  task :format do
    system("bundle exec mdl -c .mdlrc #{Dir.glob("**/*.md") * "\s"}")
    puts "#{$CHILD_STATUS.success? ? :no : :some} errors found"
  end
end

namespace :sorbet do
  desc "Type-checking with sorbet"
  task :check do
    system("bundle exec srb tc")
  end

  desc "Type-checking and auto-fix correctable errors with sorbet"
  task :autocorrect do
    system("bundle exec srb tc --autocorrect")
  end
end

namespace :tapioca do
  desc "Generate RBI from gems with tapioca"
  task :gen do
    system("bundle exec tapioca gem --all")
  end

  desc "Check duplicated definitions exists in shim RBIs with tapioca"
  task :check_shims do
    system("bundle exec tapioca check-shims")
  end
end

task :default do
  %i[mdl:format rubocop:autocorrect_all sorbet:autocorrect tapioca:check_shims spec].each do |task_name|
    padding = "=" * task_name.size
    puts <<~BANNER
      .｡*ﾟ+.*.｡　　#{padding}　　ﾟ+..｡*ﾟ+
      .｡*ﾟ+.*.｡　　#{task_name}　　ﾟ+..｡*ﾟ+
      .｡*ﾟ+.*.｡　　#{padding}　　ﾟ+..｡*ﾟ+
    BANNER
    Rake::Task[task_name].execute
  end
end
