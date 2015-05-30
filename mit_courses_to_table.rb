require 'nokogiri'
require 'open-uri'
@page = Nokogiri::HTML(open("http://student.mit.edu/catalog/m16a.html"))

def get_course_title(n)
  course_titles = []
  h3_tags = @page.xpath("//h3")
  h3_tags.each do |h3_tag|
    h3_tag_text = h3_tag.text.split("\n")
    course_titles << h3_tag_text[0] if /\d.*$/.match(h3_tag.text[0])
  end
  return course_titles[n]
end
