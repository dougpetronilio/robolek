require File.join(File.dirname(__FILE__), "..", "..", "lib", "robo_lek")

require "simplecov"
require "simplecov-rcov"

SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start