module SeoHelper
  def meta_description(text)
    content_for(:meta_description, strip_tags(text.to_s).squish.truncate(160))
  end

  def og_title(text)
    content_for(:og_title, text)
  end

  def og_description(text)
    content_for(:og_description, strip_tags(text.to_s).squish.truncate(200))
  end

  def og_image(url)
    content_for(:og_image, url)
  end

  def og_type(type)
    content_for(:og_type, type)
  end

  def canonical_url(url)
    content_for(:canonical_url, url)
  end

  def course_structured_data(course)
    data = {
      "@context" => "https://schema.org",
      "@type" => "Course",
      "name" => course.name,
      "provider" => {
        "@type" => "Organization",
        "name" => "Kurzy",
        "url" => root_url
      },
      "offers" => {
        "@type" => "Offer",
        "price" => format_price_for_schema(course),
        "priceCurrency" => course.currency,
        "availability" => "https://schema.org/InStock",
        "url" => course_url(course)
      }
    }

    if course.description&.body&.present?
      data["description"] = course.description.body.to_plain_text.squish.truncate(300)
    end

    if course.cover_image.attached?
      data["image"] = rails_blob_url(course.cover_image)
    end

    chapters_count = course.chapters.size
    if chapters_count > 0
      data["hasCourseInstance"] = [{
        "@type" => "CourseInstance",
        "courseMode" => "online",
        "courseWorkload" => "#{chapters_count} kapitol"
      }]
    end

    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  private

  def format_price_for_schema(course)
    if Course::ZERO_DECIMAL_CURRENCIES.include?(course.currency.to_s.upcase)
      course.price.to_s
    else
      format("%.2f", course.price / 100.0)
    end
  end
end
