require 'nokogiri'
require 'open-uri'
require './core_coverage_fetch_logic'

REPO_PATH = ENV['REPO_ROOT'] + "/code_coverage_dashboard"
go_coverage_file_path = "#{REPO_PATH}/samples/gocov_report.html"
jacoco_coverage_file_path = "#{REPO_PATH}/samples/jacoco_report.html"
scct_coverage_file_path = "#{REPO_PATH}/samples/scct_report.html"
istanbul_coverage_file_path = "#{REPO_PATH}/samples/istanbul_jasmine_report.html"

go_cov_map = Hash.new({ value: 0 })
istanbul_cov_map = Hash.new({ value: 0 })

scct_cov_map = Hash.new({ value: 0 })
jacoco_cov_map = Hash.new({ value: 0 })

# Golang coverage reports
SCHEDULER.every '10s' do
  go_cov_map = fetch_go_coverage_numbers(go_coverage_file_path)
  send_event('go', { items: go_cov_map.values })
end

# Istanbul-Jasmine coverage reports
SCHEDULER.every '10s' do
  istanbul_cov_map = fetch_jasmine_coverage_numbers(istanbul_coverage_file_path)
  send_event('istanbul', { items: istanbul_cov_map.values })
end

# Scct coverage reports
SCHEDULER.every '1m' do
  # scct_cov_map = fetch_app_scct_coverage_numbers(scct_coverage_file_path)
  scct_cov_map = fetch_scct_coverage_numbers(scct_coverage_file_path, "Controller")
  send_event('scct', { items: scct_cov_map.values })
end

# Jacoco reports
SCHEDULER.every '10s' do
  jacoco_cov_map = fetch_jacoco_coverage_numbers(jacoco_coverage_file_path, "TestApp")
  send_event('jacoco', { items: jacoco_cov_map.values })
end