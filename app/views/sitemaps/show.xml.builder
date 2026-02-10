xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc root_url
    xml.changefreq "weekly"
    xml.priority "1.0"
  end

  xml.url do
    xml.loc courses_url
    xml.changefreq "weekly"
    xml.priority "0.9"
  end

  @courses.each do |course|
    xml.url do
      xml.loc course_url(course)
      xml.lastmod course.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.8"
    end
  end

  xml.url do
    xml.loc terms_url
    xml.changefreq "monthly"
    xml.priority "0.3"
  end

  xml.url do
    xml.loc privacy_url
    xml.changefreq "monthly"
    xml.priority "0.3"
  end
end
