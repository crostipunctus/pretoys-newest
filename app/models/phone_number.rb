# Normalizes phone numbers to E.164 ("+919876543210") and pulls them out of
# whatever an admin pastes: a list of numbers, "Name, number" rows, or a
# WhatsApp chat export.
module PhoneNumber
  Entry = Data.define(:phone, :name)

  # WhatsApp exports wrap numbers in bidi marks and use non-breaking spaces.
  INVISIBLE = /[‎‏‪-‮⁦-⁩]/
  CANDIDATE = /(?<![\w+])\+?\d[\d \-().  ]{6,18}\d(?!\w)/
  NAME = /\A\p{L}[\p{L}\p{M} .'’]{0,40}\z/

  module_function

  def normalize(raw, country_code: default_country_code)
    text = raw.to_s.gsub(INVISIBLE, "").strip
    digits = text.gsub(/\D/, "")
    return if digits.empty?

    if text.start_with?("+") then "+#{digits}"
    elsif digits.start_with?("00") then "+#{digits.delete_prefix("00")}"
    elsif digits.start_with?("0") then "+#{country_code}#{digits.sub(/\A0+/, "")}"
    elsif digits.length > 10 then "+#{digits}"
    else "+#{country_code}#{digits}"
    end
  end

  def extract(text, country_code: default_country_code)
    entries = {}

    text.to_s.gsub(INVISIBLE, "").each_line do |line|
      candidates = line.scan(CANDIDATE).select { |candidate| plausible?(candidate) }
      name = name_from(line, candidates.first) if candidates.one?

      candidates.each do |candidate|
        phone = normalize(candidate, country_code: country_code)
        entries[phone] = Entry.new(phone: phone, name: entries[phone]&.name || name)
      end
    end

    entries.values
  end

  def plausible?(candidate)
    digits = candidate.gsub(/\D/, "").length
    digits.between?(candidate.start_with?("+") ? 8 : 10, 15)
  end

  def name_from(line, candidate)
    rest = line.sub(candidate, " ").gsub(/[\s,;:|\-–—~•*\t]+/, " ").strip
    rest if rest.match?(NAME)
  end

  def default_country_code
    Rails.configuration.x.default_country_code
  end
end
