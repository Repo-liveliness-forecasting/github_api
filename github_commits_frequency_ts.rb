require_relative 'lib/github_repository'

USAGE = 'USAGE: ruby github_commits_frequency_ts.rb <OWNER> <REPO>'.freeze
CREDENTIALS = YAML.load(File.read('config/github_credential.yml'))
OUTPUT_FOLDER = './output/'.freeze

def exit_with_error(msg)
  puts "#{msg}\n"
  puts
  exit(false)
end

def valid_arguments_or_die(arguments)
  owner, repo = arguments
  exit_with_error(USAGE) unless owner and repo
  filename = owner + '_' + repo + '_commits.csv'
  [owner, repo, filename]
end

owner, repo, filename = valid_arguments_or_die(ARGV)

github_api = Github::API.new(
  CREDENTIALS[:username],
  CREDENTIALS[:token]
)

repository = Github::Repository.new(github_api, owner, repo)

File.write(OUTPUT_FOLDER + filename, repository.commits_to_csv)
