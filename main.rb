require 'rubygems'
require 'mechanize'
require 'gemnasium/parser'
require 'trollop'
require 'net/http'
require 'json'

opts = Trollop::options do
  opt :filepath, "Path to the dependency definitions (Gemfile or package.json)", :type => :string
  opt :summary, "Get a summary of licenses found", :type => :boolean, :default => false
end

def find_license_for_gem(gem_name)
  agent = Mechanize.new
  license = agent.get("https://rubygems.org/gems/#{gem_name}").search('div.licenses p')
  if !license.empty? && license[0]
    license[0].content
  else
    "n/A"
  end
end

def jump_hoops_for_the_license_of(gem)
  agent = Mechanize.new
  url = agent.get("https://rubygems.org/gems/#{gem}").search("//a[contains(text(), 'Source Code')]/@href")

  if url.empty?
    url = agent.get("https://rubygems.org/gems/#{gem}").search("//a[contains(text(), 'Homepage')]/@href")
  end

  return "n/A" if url.empty?
  #Yes! We have a link to the Github repository
  license_url  = agent.get(url).search("//a[contains(text(), 'LICENSE')]/@href")
  license_text = Net::HTTP.get_response(URI.parse("https://github.com#{license_url[0]}")).body

  if license_text.include? "MIT License"
    "MIT"
  elsif license_text.include? "BSD"
    "BSD"
  else
    "n/A"
  end

end

def get_license_for_npm_module(module_name)
  agent = Mechanize.new
  license = agent.get("https://npmjs.org/bower").search("//tr[th//text()[contains(., 'License')]]/td")[0].content.strip

  return (license.empty? ? "n/A" : license)

end

$license_count = 0
$licenses      = {}
$num_deps      = 0

def count_license(dependency_name, license_name)
  puts "#{dependency_name}: #{license_name}"
  if license_name != "n/A"
    $license_count = $license_count + 1
    $licenses[license_name] = if $licenses[license_name]
                                $licenses[license_name] + 1
                              else
                                $licenses[license_name] = 1
                              end
  end
end

def parse_gemfile(gemfile)
  gemfile.dependencies.each do |dependency|
    license = find_license_for_gem(dependency.name)

    if license != "n/A"
      count_license(dependency.name, license)
    else
      begin
        license = jump_hoops_for_the_license_of(dependency.name)
        count_license(dependency.name, license)
      rescue => e
      end
    end
  end
end

def parse_npm_deps(json)
  $num_deps = json["dependencies"].keys.count
  json["dependencies"].each_key do |dep|
    license = get_license_for_npm_module(dep)
    count_license(dep, license)
  end
end


#######################
# Let the games begin #
#######################


if File.basename(opts[:filepath]) == "Gemfile"
  gemfile = Gemnasium::Parser.gemfile(File.read(opts[:filepath]))
  $num_deps = gemfile.dependencies.count
  parse_gemfile(gemfile)
else
  begin
    package_json = JSON.parse(File.read(opts[:filepath]))
    parse_npm_deps(package_json)
  rescue => e
    puts "Can't parse JSON: #{e}"
  end
end


puts "Found #{$license_count} licenses from #{$num_deps} dependencies"

$licenses.each { |license, count| puts "#{license}: #{count}x" } if opts[:summary]
