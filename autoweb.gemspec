$LOAD_PATH.unshift 'lib'
require "autoweb/version" 
Gem::Specification.new do |s|
  s.name = %q{autoweb}
  s.version = Autoweb::VERSION
  s.has_rdoc = true
  s.required_ruby_version = ">= 1.8.7"
  s.platform = "ruby"
  s.required_rubygems_version = ">= 0"
  s.author = "dazuiba"
  s.email = %q{come2u@gmail.com}
  s.summary = %q{Gem for the rest}
  s.homepage = %q{http://github.com/dazuiba/autoweb.git}
  s.description = %q{Automate the Internet. baidu music downloader}
  s.executables = %w(autoweb)
  
  s.files = %w( README.rdoc )
  s.files += Dir.glob("lib/**/*")
  s.files += Dir.glob("commands/**/*")
  s.files += Dir.glob("bin/*")
end
