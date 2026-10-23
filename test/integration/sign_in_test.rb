require "test_helper"

class SignInTest < ActionDispatch::IntegrationTest
  test "a member from the group signs in with a code sent to their number" do
    get listings_path
    assert_redirected_to new_session_path

    post session_path, params: { phone: "99000 00002" }
    assert_redirected_to new_verification_path
    delivery = SignInCodeDelivery.deliveries.last
    assert_equal "+919900000002", delivery[:to]

    post verification_path, params: { code: delivery[:code] }
    assert_redirected_to listings_url

    follow_redirect!
    assert_response :success
    assert_select "h1", /Priya/
  end

  test "a number outside the circle is turned away" do
    post session_path, params: { phone: "+44 7700 900123" }

    assert_response :unprocessable_entity
    assert_match "invite-only", response.body
    assert_empty SignInCodeDelivery.deliveries
  end

  test "a wrong code does not sign in" do
    post session_path, params: { phone: members(:priya).phone }
    code = SignInCodeDelivery.deliveries.last[:code]

    post verification_path, params: { code: code == "123456" ? "654321" : "123456" }
    assert_response :unprocessable_entity

    get listings_path
    assert_redirected_to new_session_path
  end

  test "an imported member without a name is asked for one first" do
    sign_in_as members(:nameless)

    get listings_path
    assert_redirected_to edit_profile_path

    patch profile_path, params: { member: { name: "Fatima Khan", neighborhood: "Indiranagar" } }
    assert_redirected_to root_path
    assert_equal "Fatima Khan", members(:nameless).reload.name
  end

  test "signing out" do
    sign_in_as members(:priya)
    delete session_path
    assert_redirected_to new_session_path

    get listings_path
    assert_redirected_to new_session_path
  end
end
