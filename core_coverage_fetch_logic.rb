require 'nokogiri'
require 'open-uri'

def fetch_go_coverage_numbers(file_path)
  doc = Nokogiri::HTML(open(file_path))
  # Fetch the overview blocks:
  test_doc = doc.css("table[class='overview']")
  count = 0
  coverage_map = Hash.new({ value: 0 })
  test_doc.each_with_index do |package_data, index|
    # Loop through each of the package data
    package_name = package_data.css("td[colspan='2']").text()
    subpackage_list = package_data.css("a[href]").text()
    subpackages = subpackage_list.gsub(/[()]/, "").split("...")
    coverage_list = package_data.css("td[class='percent']").text()
    coverage = coverage_list.split("%")
    coverage.each_with_index do |val, index|
      unless index < (coverage.length - 1)
        coverage_map[count] = {label: package_name.upcase, value: coverage[index].to_i }
        count = count + 1
      end
    end
  end
  coverage_map
end

def fetch_jasmine_coverage_numbers(file_path)
  doc = Nokogiri::HTML(open(file_path))
  coverage_map = Hash.new({ value: 0 })
  # Titles of type of coverage:
  coverage_type = ["Statements", "Branches", "Functions", "Lines"]
  coverage_value = doc.css("div[class='header medium']").css("h2").css("span[class='metric']").text()
  coverage = coverage_value.split(/[\(|)]/).reject! {|item| item.match('\/')}
  coverage.each_with_index do |val, index|
    coverage_map[index] = {label: coverage_type[index], value: coverage[index].to_i }
  end
  coverage_map
end

def fetch_scct_coverage_numbers(file_path, package)
  begin
    count = 0
    doc = Nokogiri::HTML(open(file_path))
    coverage_map = Hash.new({ value: 0 })
    coverage_value = doc.css("div[class='content']").css("div[class='pkgRow header']").text()
    coverage = coverage_value.strip.gsub("Summary ", "").gsub(" %", "")
    coverage_map[count] = {label: package.upcase, value: coverage.to_i }
    count = count + 1
  rescue => e
    puts "Encountered following error: #{e.message}"
    exit 1
  end
  coverage_map
end

def fetch_jacoco_coverage_numbers(file_path, package)
  begin
    doc = Nokogiri::HTML(open(file_path))
    coverage_map = Hash.new({ value: 0 })
    coverage_type = ["#{package}-Instructions", "#{package}-Branches"]
    coverage_value = doc.css("table[class='coverage']").css("td[class='ctr2']").text()
    coverage = coverage_value.split("%")
    coverage_type.each_with_index do |val, index|
      coverage_map[index] = {label: coverage_type[index], value: coverage[index].to_i }
    end
  rescue => e
    puts "Encountered following error: #{e.message}"
    exit 1
  end
  coverage_map
end

# Utility function to merge hashes into a single hash
def merge_hash(final_hash, new_hash)
  new_hash.each do |key, val|
    final_hash[final_hash.size] = new_hash[key]
  end
  final_hash
end

# Fetch coverage numbers for a project with multiple coverage reports.
def fetch_app_coverage_numbers(root_path)
  app_app_list = ["core", "app1", "app2", "app3"]
  final_coverage_map = {}
  app_app_list.each do |app|
    file_path = "#{root_path}#{app}/target/scala-2.10/jacoco/html/index.html"
    coverage = fetch_jacoco_coverage_numbers(file_path, app)
    final_coverage_map = merge_hash(final_coverage_map, coverage)
  end
  final_coverage_map
end