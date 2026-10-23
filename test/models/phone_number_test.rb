require "test_helper"

class PhoneNumberTest < ActiveSupport::TestCase
  test "normalizes common formats to E.164" do
    assert_equal "+919876543210", PhoneNumber.normalize("98765 43210", country_code: "91")
    assert_equal "+919876543210", PhoneNumber.normalize("+91 98765-43210")
    assert_equal "+919876543210", PhoneNumber.normalize("09876543210", country_code: "91")
    assert_equal "+919876543210", PhoneNumber.normalize("0091 98765 43210")
    assert_equal "+919876543210", PhoneNumber.normalize("919876543210")
    assert_equal "+447700900123", PhoneNumber.normalize("07700 900123", country_code: "44")
    assert_nil PhoneNumber.normalize("  ")
  end

  test "extracts numbers and names from a pasted list" do
    entries = PhoneNumber.extract(<<~TEXT, country_code: "91")
      Priya Sharma, +91 98765 43210
      Anjali: 99887 76655
      9123456789
      Priya again +91 98765 43210
    TEXT

    assert_equal [ "+919876543210", "+919988776655", "+919123456789" ], entries.map(&:phone)
    assert_equal [ "Priya Sharma", "Anjali", nil ], entries.map(&:name)
  end

  test "extracts numbers from a WhatsApp chat export without mistaking messages for names" do
    entries = PhoneNumber.extract(<<~TEXT, country_code: "91")
      23/10/26, 10:15 - ‪+91 98765 43210‬: Anyone have a baby gym?
      [23/10/26, 10:16:32] Priya Sharma: I do!
      23/10/26, 10:20 - Priya Sharma added ‪+91 99887 76655‬
    TEXT

    assert_equal [ "+919876543210", "+919988776655" ], entries.map(&:phone)
    assert entries.all? { |entry| entry.name.nil? }
  end
end
