require 'nokogiri'
require 'open-uri'
require 'erb'
require 'sinatra'
require 'net/http'

get '/' do
  erb :index
end

get '/table' do
  @courses_category = "a"
  @page = ""
  while Net::HTTP.get_response(URI.parse(
    "http://student.mit.edu/catalog/m#{params['course']}#{@courses_category}.html"
    )).code == "200"
    @page += Nokogiri::HTML(open(
     "http://student.mit.edu/catalog/m#{params['course']}#{@courses_category}.html"
     )).to_s
    @courses_category = @courses_category.next
  end

  @page.gsub!(/<a name="\d.*$/, "</div>\n<div class='course'>\n\\0")
  @all_courses = Nokogiri::HTML(@page).xpath("//div[@class='course']")
  @courses = @all_courses.dup

  def get_num(n)
    @courses[n].xpath("h3").text.match(/^([\d\.a-zA-Z\-]*(, [\d\.a-zA-Z\-]*)*?) (.*)$/)[1]
  end

  def get_title(n)
    @courses[n].xpath("h3").text.match(/^([\d\.a-zA-Z\-]*(, [\d\.a-zA-Z\-]*)*?) (.*)$/)[-1]
  end

  def get_instructors(n)
    instructors_xml = @courses[n].xpath("i")[-1]
    if !instructors_xml.nil?
      return "Staff" if instructors_xml.text.match(/^Staff/)
      return instructors_xml.text if instructors_xml.text.match(/^[A-Z]\./) or 
        instructors_xml.text.match(/^Consult/)
    else
      consult = @courses[n].text.match(/^Consult [A-Z]\. ([A-Z]\. )?[A-Z][a-z]*/)
      return consult[0] unless consult.nil?
    end
  end

  def get_units(n)
    units_match_data = @courses[n].text.match(/^Units: (.*)$/)
    if units_match_data.nil?
      "Arranged" if @courses[n].text.match(/^Units arranged/)
    else
      units_match_data[1]
    end
  end

  def get_level(n)
    images = @courses[n].xpath("img//@src").to_s
    if images.match(/under.gif/)
      "U"
    elsif images.match(/grad.gif/)
      "G"
    end
  end

  def is_spring?(n)
    images = @all_courses[n].xpath("img//@src").to_s
    if images.match(/spring.gif/)
      true
    else
      false
    end
  end

  def is_fall?(n)
    images = @all_courses[n].xpath("img//@src").to_s
    if images.match(/fall.gif/)
      true
    else
      false
    end
  end

  def is_iap?(n)
    images = @all_courses[n].xpath("img//@src").to_s
    if images.match(/iap.gif/)
      true
    else
      false
    end
  end

  def is_summer?(n)
    images = @all_courses[n].xpath("img//@src").to_s
    if images.match(/summer.gif/)
      true
    else
      false
    end
  end

  def is_offered?(n)
    images = @all_courses[n].xpath("img//@src").to_s
    if images.match(/nooffer.gif/)
      false
    else
      true
    end
  end

  def get_lecture(n)
    lecture_match_data = @courses[n].text.match(/Lecture: ([\S]*( EVE \([\d\-]* PM\))? \([\S]*\))/)
    lecture_match_data[1] unless lecture_match_data.nil?
  end

  def is_lecture?(n)
    if get_lecture(n).nil? 
      false
    else
      true
    end
  end

  def get_lab(n)
    lab_match_data = @courses[n].text.match(/Lab: (([\S]* \([\S]*( LAB)?\)( or )?)*)/)
    lab_match_data[1] unless lab_match_data.nil?
  end

  def is_lab?(n)
    if get_lab(n).nil? 
      false
    else
      true
    end
  end

  def get_recitation(n)
    recitation_match_data = @courses[n].text.match(/Recitation: (([\S]* \([\S]*(, [\S]*)*?\)( or )?)*)/)
    recitation_match_data[1] unless recitation_match_data.nil?
  end

  def is_recitation?(n)
    if get_recitation(n).nil? 
      false
    else
      true
    end
  end

  def get_meets(n)
    if @courses[n].text.match(/Not offered regularly; consult department/)
      "Not offered regularly; consult department"
    elsif @courses[n].text.match(/TBA/)
      "TBA"
    elsif @courses[n].xpath("img//@src").to_s.match(/nooffer.gif/)
      "Not offered this academic year"
    else
      meets = ""
      meets += "<p>Lecture: #{get_lecture(n)}</p>" if is_lecture?(n)
      meets += "<p>Lab: #{get_lab(n)}</p>" if is_lab?(n)
      meets += "<p>Recitation: #{get_recitation(n)}</p>" if is_recitation?(n)
      meets
    end
  end

  case params['term']
  when "fall"
    @all_courses.each_with_index do |course, index|
      @courses.delete(course) if !is_fall?(index) or 
        (params['hide_not_offered'] == "1" and !is_offered?(index))
    end
  when "spring"
    @all_courses.each_with_index do |course, index|
      @courses.delete(course) unless is_spring?(index) or
        (params['hide_not_offered'] == "1" and !is_offered?(index))
    end
  when "iap"
    @all_courses.each_with_index do |course, index|
      @courses.delete(course) unless is_iap?(index) or
        (params['hide_not_offered'] == "1" and !is_offered?(index))
    end
  when "summer"
    @all_courses.each_with_index do |course, index|
      @courses.delete(course) unless is_summer?(index) or
        (params['hide_not_offered'] == "1" and !is_offered?(index))
    end
  else
    @all_courses.each_with_index do |course, index|
      @courses.delete(course) if params['hide_not_offered'] == "1" and !is_offered?(index)
    end
  end  
 
  erb :template
end
