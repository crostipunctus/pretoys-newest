# Sends the 6-digit sign-in code. Configure Twilio to send it by SMS, or by
# WhatsApp with TWILIO_FROM="whatsapp:+14155238886" (the number must be a
# Twilio WhatsApp sender). Without Twilio, development just logs the code.
class SignInCodeDelivery
  cattr_accessor :deliveries, default: []

  def self.deliver(phone, code)
    body = "#{code} is your Pretoys sign-in code. It expires in 10 minutes."

    if Rails.env.test?
      deliveries << { to: phone, code: code }
    elsif ENV["TWILIO_ACCOUNT_SID"].present?
      send_with_twilio(phone, body)
    elsif Rails.env.development?
      Rails.logger.info "[SignInCodeDelivery] #{phone}: #{body}"
    else
      raise "Set TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN and TWILIO_FROM to send sign-in codes"
    end
  end

  def self.send_with_twilio(phone, body)
    from = ENV.fetch("TWILIO_FROM")
    to = from.start_with?("whatsapp:") ? "whatsapp:#{phone}" : phone
    uri = URI("https://api.twilio.com/2010-04-01/Accounts/#{ENV.fetch("TWILIO_ACCOUNT_SID")}/Messages.json")

    request = Net::HTTP::Post.new(uri)
    request.basic_auth(ENV.fetch("TWILIO_ACCOUNT_SID"), ENV.fetch("TWILIO_AUTH_TOKEN"))
    request.set_form_data("To" => to, "From" => from, "Body" => body)

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(request) }
    raise "Twilio error #{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)
  end
end
