#!/usr/bin/env ruby
# encoding: UTF-8
#

# The libraries we need
#
require 'cgi'
require 'mysql2'
require 'erb'
require 'json'
require 'rubygems'
require 'sanitize'

# Pull in our own functions
#
require_relative 'lib/db_func'
require_relative 'lib/code_func'
require_relative 'lib/form_func'
require_relative 'lib/gem_func'

# Start this as a CGI
#
cgi = CGI.new
puts cgi.header('charset'=>'utf-8')

# Root dir
#
docroot = '/var/www/html/gematria'

# Connect to the DB
#
connectDB()

# CGI parameters
#
s = cgi['s']
l = cgi['l']
e = cgi['e']

# The encoding popup
#
encodingpopup = getEncodingPopup(l)

# Did I ask for a specific entry?
#
if (e.to_i > 0)
  # Yes.  Show it.
  output = e.to_i.showEntry
else
  # No.  Do the gematria.
  output = s.doGematria(l)
end

# And output the results
#
template = ERB.new(File.read("#{docroot}/gem_temp.erb"))
puts template.result(binding)
