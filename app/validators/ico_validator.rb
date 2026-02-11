class IcoValidator < ActiveModel::EachValidator
  WEIGHTS = [8, 7, 6, 5, 4, 3, 2].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    digits = value.to_s.gsub(/\s/, "")
    unless digits.match?(/\A\d{8}\z/)
      record.errors.add(attribute, "musí mít 8 číslic")
      return
    end

    sum = digits[0..6].chars.each_with_index.sum { |d, i| d.to_i * WEIGHTS[i] }
    check = (11 - (sum % 11)) % 10
    unless check == digits[7].to_i
      record.errors.add(attribute, "není platné IČO")
    end
  end
end
