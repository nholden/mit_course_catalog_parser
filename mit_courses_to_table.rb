require 'nokogiri'
require 'open-uri'
require 'erb'

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
  @courses[n].xpath("i")[-1].text unless @courses[n].xpath("i")[-1].nil?
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

def get_lecture_times(n)
  lecture_match_data = @courses[n].text.match(/Lecture: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
  lecture_match_data[1] unless lecture_match_data.nil?
end

def get_lecture_room(n)
  lecture_match_data = @courses[n].text.match(/Lecture: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
  lecture_match_data[2] unless lecture_match_data.nil?
end 

def get_lab_times(n)
  two_labs_match_data = @courses[n].text.match(/Lab: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\) or ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
  if two_labs_match_data.nil?
    lab_match_data = @courses[n].text.match(/Lab: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
    lab_match_data[1] unless lab_match_data.nil?
  else
    [two_labs_match_data[1], two_labs_match_data[3]]
  end
end

def get_lab_room(n)
  two_labs_match_data = @courses[n].text.match(/Lab: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\) or ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
  if two_labs_match_data.nil?
    lab_match_data = @courses[n].text.match(/Lab: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
    lab_match_data[2] unless lab_match_data.nil?
  else
    [two_labs_match_data[2], two_labs_match_data[4]]
  end
end

def get_recitation_times(n)
  two_recitations_match_data = @courses[n].text.match(/Recitation: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\) or ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
  if two_recitations_match_data.nil?
    recitation_match_data = @courses[n].text.match(/Recitation: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
    recitation_match_data[1] unless recitation_match_data.nil?
  else
    [two_recitations_match_data[1], two_recitations_match_data[3]]
  end
end

def get_recitation_room(n)
  two_recitations_match_data = @courses[n].text.match(/Recitation: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\) or ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
  if two_recitations_match_data.nil?
    recitation_match_data = @courses[n].text.match(/Recitation: ([a-zA-Z\d]*) \(([a-zA-Z\d-]*)\)/)
    recitation_match_data[2] unless recitation_match_data.nil?
  else
    [two_recitations_match_data[2], two_recitations_match_data[4]]
  end
end

template = File.read('template.html.erb')
File.open('table.html', 'w+') { |file| file.write(ERB.new(template).result) }
