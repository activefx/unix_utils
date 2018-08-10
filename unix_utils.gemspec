# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

require "unix_utils/version"

Gem::Specification.new do |s|
  s.name          = "unix_utils"
  s.version       = UnixUtils::VERSION
  desc = %q{Like FileUtils, but provides zip, unzip, bzip2, bunzip2, tar, untar, sed, du, md5sum, shasum, cut, head, tail, wc, unix2dos, dos2unix, iconv, curl, perl, etc.}
  s.summary       = desc
  s.description   = desc
  s.author        = ["Seamus Abshere"]
  s.email         = ["seamus@abshere.net"]
  s.homepage      = "https://github.com/seamusabshere/unix_utils"
  s.license       = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.0.0"

  s.add_development_dependency "bundler",           "~> 1.15"
  s.add_development_dependency "rake",              ">= 10.0"
  s.add_development_dependency "rspec",             "~> 3.7"
end
