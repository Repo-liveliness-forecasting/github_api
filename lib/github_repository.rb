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

    def to_csv
      headers = "datetime, commit_sha \n"
      data = commits.map { |row| row.join(SEPERATOR) + NEWLINE }.join
      headers + data
    end
  end
end
