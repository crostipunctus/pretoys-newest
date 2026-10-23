require "test_helper"

class InvitesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as members(:asha) }

  test "a member vouches for a new mom, who can then sign in" do
    post invites_path, params: { member: { name: "Meera Iyer", phone: "98450 12345" } }

    meera = Member.find_by!(phone: "+919845012345")
    assert meera.invite?
    assert_equal members(:asha), meera.invited_by
    assert_redirected_to invite_path(meera)

    follow_redirect!
    assert_select "a.btn-whatsapp[href^='https://wa.me/919845012345']"
  end

  test "inviting someone already in the circle" do
    assert_no_difference -> { Member.count } do
      post invites_path, params: { member: { name: "Priya", phone: members(:priya).phone } }
    end
    assert_redirected_to member_path(members(:priya))
  end
end
