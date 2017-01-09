require 'csv'

USAGE = 'USAGE: ruby github_issue_daily_aggregation.rb <owner> <repo>'.freeze
OUTPUT_FOLDER = './output/'.freeze
NEWLINE = "\n".freeze
SEPERATOR = ", ".freeze

def exit_with_error(msg)
  puts "#{msg}\n"
  puts
  exit(false)
end

def valid_arguments_or_die(arguments)
  owner, repo = arguments
  issue_csv = CSV.read(OUTPUT_FOLDER + [owner, repo, 'issues.csv'].join('_'), headers: true)
  commit_csv = CSV.read(OUTPUT_FOLDER + [owner, repo, 'commits.csv'].join('_'), headers: true)
  exit_with_error(USAGE) if (issue_csv.nil? || commit_csv.nil?)
  filepath = OUTPUT_FOLDER + [owner, repo, 'daily.csv'].join('_')
  [filepath, issue_csv, commit_csv]
end

def get_aggregated_hash(issue_csv, commit_csv)
  file_aggregated = {}

  issue_csv.each do |row|
    date = Date.parse(row['datetime']).to_s
    unless file_aggregated[date]
      file_aggregated[date] = {
        number_of_issues: 0,
        number_of_pull_requests: 0,
        number_of_commits: 0
      }
    end
    file_aggregated[date][:number_of_issues] += 1
    file_aggregated[date][:number_of_pull_requests] += row[2] == ' true'? 1 : 0
  end

  commit_csv.each do |row|
    date = Date.parse(row['datetime']).to_s
    unless file_aggregated[date]
      file_aggregated[date] = {
        number_of_issues: 0,
        number_of_pull_requests: 0,
        number_of_commits: 0
      }
    end
    file_aggregated[date][:number_of_commits] += 1
  end

  file_aggregated
end

def hash_to_csv(hash)
  headers = 'date, number_of_issues, number_of_pull_requests, number_of_commits' + NEWLINE

  data = hash.map do |key, value|
    [key, value[:number_of_issues], value[:number_of_pull_requests], value[:number_of_commits]].join(SEPERATOR) + NEWLINE
  end

  headers + data.reverse.join
end

filepath, issue_csv, commit_csv = valid_arguments_or_die(ARGV)
issue_aggregated = get_aggregated_hash(issue_csv, commit_csv)
File.write(filepath, hash_to_csv(issue_aggregated))
