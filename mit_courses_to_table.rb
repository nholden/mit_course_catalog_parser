require 'nokogiri'
require 'open-uri'
page = Nokogiri::HTML(open("http://student.mit.edu/catalog/m16a.html")).to_s
page.gsub!(/<a name="\d.*$/, "<div class='course'>\n\\0").gsub!(/<!--end-->/, "\\0\n</div>")
@courses = Nokogiri::HTML(page).xpath("//div[@class='course']")

def get_num(n)
  @courses[n].xpath("a")[0].xpath("@name")
end

def get_title(n)
  @courses[n].xpath("h3").text.match(/^[\d\.a-zA-Z]* (.*)$/)[1]
end

def get_instructors(n)
  @courses[n].xpath("i")[-1].text
end

def get_units(n)
  units_match_data = @courses[n].text.match(/^Units: (.*)$/)
  units_match_data[1] unless units_match_data.nil?
end

def get_level(n)
  images = @courses[n].xpath("img//@src").to_s
  if images.match(/under.gif/)
    "U"
  elsif images.match(/grad.gif/)
    "G"
  end
end

def get_lectures(n)
  lectures_match_data = @courses[n].text.match(/Lecture: ([a-zA-Z\d]*) (\([a-zA-Z\d-]*\))/)
  lectures_match_data[1] unless lectures_match_data.nil?
end
