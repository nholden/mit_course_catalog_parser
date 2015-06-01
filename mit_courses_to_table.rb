require 'nokogiri'
require 'open-uri'
require 'erb'
require 'sinatra'

get '/' do
  erb :index
end

get '/table' do
  page = Nokogiri::HTML(open("http://student.mit.edu/catalog/#{params['url']}")).to_s
  page.gsub!(/<a name="\d.*$/, "</div>\n<div class='course'>\n\\0")
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

  def is_spring?(n)
    images = @courses[n].xpath("img//@src").to_s
    if images.match(/spring.gif/)
      true
    else
      false
    end
  end

  def is_fall?(n)
    images = @courses[n].xpath("img//@src").to_s
    if images.match(/fall.gif/)
      true
    else
      false
    end
  end

  def is_iap?(n)
    images = @courses[n].xpath("img//@src").to_s
    if images.match(/iap.gif/)
      true
    else
      false
    end
  end

  def is_summer?(n)
    images = @courses[n].xpath("img//@src").to_s
    if images.match(/summer.gif/)
      true
    else
      false
    end
  end

  def get_lecture(n)
    lecture_match_data = @courses[n].text.match(/Lecture: ([\S]* \([\S]*\))/)
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
    lab_match_data = @courses[n].text.match(/Lab: (([\S]* \([\S]*\)( or )?)*)/)
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
    recitation_match_data = @courses[n].text.match(/Recitation: (([\S]* \([\S]*\)( or )?)*)/)
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
    meets = ""
    meets += "<p>Lecture: #{get_lecture(n)}</p>" if is_lecture?(n)
    meets += "<p>Lab: #{get_lab(n)}</p>" if is_lab?(n)
    meets += "<p>Recitation: #{get_recitation(n)}</p>" if is_recitation?(n)
    meets
  end

  erb :template
end
