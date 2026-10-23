# Sample data for development. In production, create the admin with
#   bin/rails circle:admin PHONE=+91... NAME="..."
# and import the WhatsApp group from the Circle page.
return unless Rails.env.development?

admin = Member.find_or_create_by!(phone: "+919900000001") do |member|
  member.name = "Roshni Admin"
  member.neighborhood = "Indiranagar"
  member.admin = true
  member.joined_at = 3.months.ago
end

founders = [
  [ "+919900000002", "Priya Sharma", "Koramangala" ],
  [ "+919900000003", "Anjali Menon", "HSR Layout" ],
  [ "+919900000004", "Fatima Khan", "Indiranagar" ],
  [ "+919900000005", nil, nil ]
].map do |phone, name, area|
  Member.find_or_create_by!(phone: phone) do |member|
    member.name = name
    member.neighborhood = area
    member.joined_at = (name ? 2.months.ago : nil)
  end
end

invited = Member.find_or_create_by!(phone: "+919900000006") do |member|
  member.name = "Asha Rao"
  member.neighborhood = "Jayanagar"
  member.source = :invite
  member.invited_by = founders.first
  member.joined_at = 2.weeks.ago
end

[
  [ founders[0], "Wooden train set, 24 pieces", 600, "vehicles", "3-5", "like_new", "Complete set with bridge and tunnel. Fits Brio tracks." ],
  [ founders[0], "Board books bundle (12 books)", 0, "books", "0-1", "good", "A bit chewed on the corners, still loved. Free to a good home!" ],
  [ founders[1], "LEGO Duplo farm", 1200, "building", "1-3", "like_new", "All animals included. Washed and sanitised." ],
  [ founders[1], "Balance bike, red", 1500, "outdoor", "3-5", "good", "Adjustable seat. Some scratches on the frame." ],
  [ founders[2], "Kitchen play set with utensils", 900, "pretend", "3-5", "good", nil ],
  [ admin, "Floor puzzle, world map (48 pc)", 250, "puzzles", "5-8", "unused", "Gift duplicate, still sealed." ],
  [ invited, "Watercolour + crayons art box", 0, "arts", "5-8", "good", "Half used. Pick up from Jayanagar 4th block." ],
  [ admin, "Snap circuits junior kit", 1800, "learning", "8+", "like_new", "Everything works, manual included." ]
].each_with_index do |(member, title, price, category, age, condition, description), index|
  member.listings.find_or_create_by!(title: title) do |listing|
    listing.price = price
    listing.category = category
    listing.age_group = age
    listing.condition = condition
    listing.description = description
    listing.neighborhood = member.neighborhood
    listing.created_at = index.days.ago
  end
end

Listing.find_by(title: "LEGO Duplo farm")&.reserved!

puts "Seeded #{Member.count} members and #{Listing.count} listings. Sign in as the admin with 99000 00001."
