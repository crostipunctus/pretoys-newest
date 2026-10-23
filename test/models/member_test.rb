require "test_helper"

class MemberTest < ActiveSupport::TestCase
  test "normalizes phone numbers so lookups match however the number is typed" do
    assert_equal members(:priya), Member.find_by(phone: "99000 00002")
  end

  test "sign-in code verifies once" do
    member = members(:nameless)
    code = member.issue_sign_in_code

    assert_not member.verify_sign_in_code("000000") if code != "000000"
    assert member.verify_sign_in_code(code)
    assert member.joined?
    assert_not member.verify_sign_in_code(code), "code should not be reusable"
  end

  test "sign-in code expires" do
    member = members(:priya)
    code = member.issue_sign_in_code

    travel 11.minutes do
      assert_not member.verify_sign_in_code(code)
    end
  end

  test "sign-in code locks after too many wrong attempts" do
    member = members(:priya)
    code = member.issue_sign_in_code
    wrong = code == "111111" ? "222222" : "111111"

    Member::MAX_SIGN_IN_ATTEMPTS.times { member.verify_sign_in_code(wrong) }
    assert_not member.verify_sign_in_code(code)
  end

  test "removing a member keeps the people they vouched for" do
    members(:priya).destroy!
    assert_nil members(:asha).reload.invited_by
  end
end
