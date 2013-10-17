require 'rubygems'
require 'mechanize'
require 'gemnasium/parser'
require 'trollop'

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

gemfile = Gemnasium::Parser.gemfile(File.read(opts[:gemfile]))

license_count = 0

licenses = {}

gemfile.dependencies.each do |dependency|
  license = find_license_for_gem(dependency.name)

  if license != "n/A"
    license_count = license_count + 1
    puts "#{dependency.name}: #{license}"
    licenses[license] = if licenses[license]
      licenses[license] + 1
    else
      puts "#{dependency.name}: ?"
      licenses[license] = 1 
    end
  end
end

puts "found #{license_count} from #{gemfile.dependencies.count} dependencies"

licenses.each { |license, count| puts "#{license}: #{count}x" } if opts[:summary]
