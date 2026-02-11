class DicValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    cleaned = value.to_s.gsub(/\s/, "").upcase
    unless cleaned.match?(/\ACZ\d{8,10}\z/)
      record.errors.add(attribute, "musí být ve formátu CZ + 8-10 číslic (např. CZ12345678)")
    end
  end
end
