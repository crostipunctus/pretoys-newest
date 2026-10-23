namespace :circle do
  desc "Create or promote the circle admin: bin/rails circle:admin PHONE=+919876543210 NAME='Priya'"
  task admin: :environment do
    phone = ENV.fetch("PHONE") { abort "Usage: bin/rails circle:admin PHONE=+919876543210 NAME='Your name'" }
    member = Member.find_or_initialize_by(phone: phone)
    member.update!(admin: true, name: ENV["NAME"].presence || member.name, source: member.source || :whatsapp_group)
    puts "#{member.display_name} (#{member.phone}) is now an admin. Sign in with that number, then import the group from the Circle page."
  end
end
