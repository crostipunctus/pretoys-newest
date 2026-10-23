require "test_helper"

class ListingsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as members(:priya) }

  test "browsing shows available toys and hides ones that are gone" do
    get listings_path
    assert_response :success
    assert_select ".listing-card", text: /Wooden train set/
    assert_select ".listing-card", text: /Old scooter/, count: 0
  end

  test "filters by free and search" do
    get listings_path(free: "1")
    assert_select ".listing-card", count: 1
    assert_select ".listing-card", text: /Board books/

    get listings_path(q: "train")
    assert_select ".listing-card", count: 1
    assert_select ".listing-card", text: /Wooden train/
  end

  test "listing a toy with a photo" do
    assert_difference -> { members(:priya).listings.count } do
      post listings_path, params: { listing: {
        title: "Duplo farm", price: 1200, category: "building", age_group: "1-3", condition: "like_new",
        photos: [ fixture_file_upload("toy.png", "image/png") ]
      } }
    end

    listing = Listing.last
    assert_redirected_to listing_path(listing)
    assert listing.photos.attached?
    assert_equal 10, listing.token.length
  end

  test "a buyer gets a WhatsApp link to the seller with the listing pre-filled" do
    sign_in_as members(:asha)
    get listing_path(listings(:train))

    assert_response :success
    assert_select "a.btn-whatsapp[href^='https://wa.me/919900000002?text=']"
  end

  test "signed-out visitors see a teaser without the seller's details" do
    delete session_path
    get listing_path(listings(:train))

    assert_response :success
    assert_select "meta[property='og:title'][content*='Wooden train set']"
    assert_select "a.btn-whatsapp", count: 0
    assert_no_match "919900000002", response.body
  end

  test "only the owner can edit or mark a listing" do
    patch mark_listing_path(listings(:train), status: "reserved")
    assert listings(:train).reload.reserved?

    patch mark_listing_path(listings(:books), status: "given_away")
    assert_response :not_found
    assert listings(:books).reload.available?
  end
end
