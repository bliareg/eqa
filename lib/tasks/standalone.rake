ENCODER_COMMAND = '(cd app/ && $RUBY_ENCODER --ruby 2.3 **/*.* -r -f "*.rb" -x "db/|spec/" --rails -o %{target_dir})'.freeze
namespace :standalone do
  task build: :environment do
    if valid_tools?
      tmp_dir = Dir.mktmpdir
      system(
        ENCODER_COMMAND % { target_dir: tmp_dir }
      )
      FileUtils.copy_entry(tmp_dir, 'app/')
      FileUtils.rm_f(tmp_dir)
    else
      p @errors
    end
  end
end

def valid_tools?
  @errors = [];
  git_empty_working_tree? && root_dir? && encoder_present?
end

def git_empty_working_tree?
  status = `git status --untracked-files=no -s`.split("\n").empty?
  @errors << 'Commit or stash your modified files!' unless status
  status
end

def root_dir?
  status = `git rev-parse --show-toplevel` == `pwd`
  @errors << 'Execute this command only from the root of the project!' unless status
  status
end

def encoder_present?
  status = `$RUBY_ENCODER -v `.match(/^RubyEncoder\s/)
  @errors << 'Ruby encoder with $RUBY_ENCODER must be present!' unless status
  status
end
