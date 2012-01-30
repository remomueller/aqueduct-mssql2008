# Compiling the Gem
# gem build aqueduct-mssql2008.gemspec
# gem install ./aqueduct-mssql2008-x.x.x.gem
#
# gem push aqueduct-mssql2008-x.x.x.gem
# gem list -r aqueduct-mssql2008
# gem install aqueduct-mssql2008

$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aqueduct-mssql2008/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aqueduct-mssql2008"
  s.version     = Aqueduct::Mssql2008::VERSION::STRING
  s.authors     = ["Remo Mueller"]
  s.email       = ["remosm@gmail.com"]
  s.homepage    = "https://github.com/remomueller"
  s.summary     = "Connect to Microsoft SQL 2008 through Aqueduct"
  s.description = "Connects to Microsoft SQL 2008 through Aqueduct interface"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["aqueduct-mssql2008.gemspec", "CHANGELOG.rdoc", "LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails",                       "~> 3.2.1"
  s.add_dependency "aqueduct",                    "~> 0.1.0"
  s.add_dependency "ruby-odbc",                   "=0.99994"
  s.add_dependency "activerecord-odbc-adapter",   "=2.0"
  s.add_dependency "dbd-odbc",                    "=0.2.5"

  s.add_development_dependency "sqlite3"
end
