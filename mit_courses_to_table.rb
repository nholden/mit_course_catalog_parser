require 'nokogiri'
require 'open-uri'
course_catalog_page = Nokogiri::HTML(open("http://student.mit.edu/catalog/m16a.html"))
