require 'yaml'
require 'http'

NEWLINE = "\n".freeze
SEPERATOR = ", ".freeze
USAGE = 'USAGE: ruby github_code_frequency_ts.rb <OWNER> <REPO>'.freeze
GITHUB_REPO_ENPOINT = 'https://api.github.com/repos'.freeze
OUTPUT_FOLDER = './output/'.freeze

def exit_with_error(msg)
  puts "#{msg}\n"
  puts
  exit(false)
end

def github_api_get_http(url, username, token)
  HTTP.basic_auth(:user => username, :pass => token).get(url)
end

def github_api_get(url)
  puts "Load Github API ..."
  github_credential = YAML.load(File.read('config/github_credential.yml'))
  username = github_credential[:username]
  token = github_credential[:token]
  response = github_api_get_http(url, username, token)
  while response.headers['Status'].split(' ').first == '202'
    puts "Wait github Processing try again in 2 seconds"
    sleep(2)
    response = github_api_get_http(url, username, token)
  end
  response

end

def load_api_or_die(owner, repo)
  endpoint = [GITHUB_REPO_ENPOINT, owner, repo, 'stats', 'code_frequency'].join('/')
  JSON.load github_api_get(endpoint).to_s
rescue
  exit_with_error("cannot load github api (#{endpoint})")
end

def valid_arguments_or_die(arguments)
  owner, repo = arguments
  exit_with_error(USAGE) unless owner and repo
  filename = owner + '_' + repo + '.csv'
  [owner, repo, filename]
end

def format_array(array)
  puts 'Processing ...'
  res = array.map { |row| [Date.strptime(row[0].to_s, '%s').strftime('%Y-%m-%d'), row[1], row[2]]}
  res.unshift ['Year Week', 'adding', 'removing']
  res
end

def array_to_csv(array)
  array.map { |row| row.join(SEPERATOR) + NEWLINE }.join
end

owner, repo, filename = valid_arguments_or_die(ARGV)
code_frequency_responce = load_api_or_die(owner, repo)
code_frequency_array = format_array(code_frequency_responce)
code_frequency_csv = array_to_csv(code_frequency_array)

File.write(OUTPUT_FOLDER + filename, code_frequency_csv)
