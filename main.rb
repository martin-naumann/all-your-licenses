require 'rubygems'
require 'mechanize'
require 'gemnasium/parser'
require 'trollop'
require 'net/http'

opts = Trollop::options do
  opt :gemfile, "Path to the Gemfile", :type => :string
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


#######################
# Let the games begin #
#######################


gemfile = Gemnasium::Parser.gemfile(File.read(opts[:gemfile]))

$license_count = 0
$licenses      = {}

def count_license(gem_name, license_name)
  puts "#{gem_name}: #{license_name}"
  if license_name != "n/A"
    $license_count = $license_count + 1
    $licenses[license_name] = if $licenses[license_name]
      $licenses[license_name] + 1
    else
      $licenses[license_name] = 1 
    end
  end
end

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

puts "found #{$license_count} from #{gemfile.dependencies.count} dependencies"

$licenses.each { |license, count| puts "#{license}: #{count}x" } if opts[:summary]
