require "test_helper"

class Admin::ImportsControllerTest < ActionDispatch::IntegrationTest
  test "an admin previews and imports numbers from the WhatsApp group" do
    sign_in_as members(:admin)

    post preview_admin_import_path, params: { text: "Lakshmi, 98450 11111\n+91 99000 00002\n98450 22222" }
    assert_response :success
    assert_select ".import-row", count: 3
    assert_select ".import-row.is-existing", count: 1

    assert_difference -> { Member.whatsapp_group.count }, 1 do
      post admin_import_path, params: { members: {
        "0" => { phone: "+919845011111", name: "Lakshmi", include: "1" },
        "2" => { phone: "+919845022222", name: "", include: "0" }
      } }
    end
    assert_redirected_to members_path
    assert_equal "Lakshmi", Member.find_by!(phone: "+919845011111").name
  end

  test "regular members can't import" do
    sign_in_as members(:priya)

    post admin_import_path, params: { members: { "0" => { phone: "+919845011111", include: "1" } } }
    assert_redirected_to root_path
    assert_nil Member.find_by(phone: "+919845011111")
  end
end
