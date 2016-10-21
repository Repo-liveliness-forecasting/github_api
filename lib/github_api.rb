require 'yaml'
require 'http'
require 'json'

# Create the response dumps
# Get ENDPOINT categories

module  Github
  # Main class to set up a Github User
  class API
    GITHUB_API_URL = 'https://api.github.com'.freeze

    def initialize(username, token)
      @username = username
      @token = token
    end

    def github_api_get_http(url)
      HTTP.basic_auth(user: @username, pass: @token).get(url)
    end

    def github_api_wait_cache(url)
      response = github_api_get_http(url)
      while response.headers['Status'].split(' ').first == '202'
        sleep(2)
        response = github_api_get_http(url)
      end
      response
    end

    def load_repo_commits_first(owner, repo)
      endpoint = [GITHUB_API_URL, 'repos', owner, repo, 'commits'].join('/')
      load_repo_commits_url(endpoint)
    end

    def load_repo_commits_url(url)
      response = github_api_wait_cache(url)
      [parse_link(response.headers.get('Link').first), response.parse()]
    end

    def parse_link(link)
      links = {}
      link.split(",").each do |link|
        url, rel = link.split(';')
        links[rel[6..-2]] = {
          url: url.strip[1..-2],
          page: url.split('page=')[1].strip[0..-2].to_i
        }
      end
      links
    end

    def parse_commits(commits)
      commits.map { |commit| [commit['commit']['author']['date'], commit['sha']]}
    end

    def load_repo_commits(owner, repo)
      commits = []
      link, commits_responce = load_repo_commits_first(owner, repo)
      commits += parse_commits(commits_responce)
      while link['next']
          puts link['next'][:page].to_s + '/' + link['last'][:page].to_s
          link, commits_responce = load_repo_commits_url(link['next'][:url])
          commits += parse_commits(commits_responce)
      end
      commits
    end
  end
end
