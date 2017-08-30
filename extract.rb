require "nokogiri"
require 'active_support/inflector'

FILE_NAME = "thewanderingelectricsheep.wordpress.2017-08-29.001.xml"
class WordpressExporter
  def generate!
    xml = Nokogiri::XML(open(FILE_NAME))

    xml.xpath("//item").each do |item|
      process_item!(item)
    end
  end

  def process_item!(item)
    title = item.css("title").text
    date = item.xpath("wp:post_date_gmt").text
    content = item.xpath("content:encoded").text
    paragraphed = content.lines.map { |x| "<p>#{x}</p>"}.join("")

    post =
"""
---
  title: #{title}
  date: #{date}
  draft: false
---
#{paragraphed}
"""

    type = item.xpath("wp:post_type").text

    if type == "attachment"
      # Ignore
    else
      file_name = "./wordpress/#{type}/#{title.parameterize}.html"
      write_item(file_name, post)
    end
  end

  def write_item(file_name, content)
    File.open(file_name, "w") do |f|
      f.write(content)
    end
  end
end

WordpressExporter.new.generate!
