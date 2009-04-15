require 'rubygems'
require 'erubis'
require File.join(File.dirname(__FILE__), 'extractor')

extractor = Extractor.new('hansards/2009-03-12.html')
extractor.extract_tree!

eruby = Erubis::Eruby.new(IO.read("semantic_out.html.erb"))

date = "2009-03-12"
puts eruby.result(binding())

