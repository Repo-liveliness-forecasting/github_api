require_relative 'github_api'

module  Github
  # Main class to set up a Github User
  class Repository

    NEWLINE = "\n".freeze
    SEPERATOR = ", ".freeze

    attr_reader :owner, :name

    def initialize(github_api, owner, name)
      @github_api = github_api
      @owner = owner
      @name = name
    end

    def commits
      return @commits if @commits
      @commits = @github_api.load_repo_commits(@owner, @name)
    end

    def issues(state: "all")
      return @issues if @issues
      @issues = @github_api.load_repo_issues(@owner, @name, state: state)
    end

    def issues_to_csv
      headers = "datetime, id, is_pull_request\n"
      data = issues.map { |row| row.join(SEPERATOR) + NEWLINE }.join
      headers + data
    end

    def commits_to_csv
      headers = "datetime, id\n"
      data = commits.map { |row| row.join(SEPERATOR) + NEWLINE }.join
      headers + data
    end
  end
end
