class Member < ApplicationRecord
  SIGN_IN_CODE_TTL = 10.minutes
  MAX_SIGN_IN_ATTEMPTS = 5

  belongs_to :invited_by, class_name: "Member", optional: true
  has_many :invitees, class_name: "Member", foreign_key: :invited_by_id, inverse_of: :invited_by, dependent: :nullify
  has_many :sessions, dependent: :destroy
  has_many :listings, dependent: :destroy

  # whatsapp_group: imported from the original group (the founding members).
  # invite: vouched for by an existing member.
  enum :source, { whatsapp_group: "whatsapp_group", invite: "invite" }, validate: true

  normalizes :phone, with: ->(phone) { PhoneNumber.normalize(phone) }
  normalizes :name, :neighborhood, with: ->(value) { value.squish.presence }

  validates :phone, presence: true, uniqueness: true, format: { with: /\A\+\d{8,15}\z/, message: "doesn't look like a phone number" }
  validates :name, length: { maximum: 60 }
  validates :name, presence: true, on: :profile

  scope :joined, -> { where.not(joined_at: nil) }
  scope :pending, -> { where(joined_at: nil) }
  scope :alphabetical, -> { order(Arel.sql("name IS NULL, LOWER(name)")) }

  def display_name
    name || "Member #{masked_phone}"
  end

  def first_name
    name&.split&.first || display_name
  end

  def joined?
    joined_at.present?
  end

  def masked_phone
    "•••• #{phone.last(4)}"
  end

  def issue_sign_in_code
    code = format("%06d", SecureRandom.random_number(1_000_000))
    update!(sign_in_code_digest: digest(code), sign_in_code_sent_at: Time.current, sign_in_code_attempts: 0)
    code
  end

  def sign_in_code_usable?
    sign_in_code_digest.present? &&
      sign_in_code_sent_at > SIGN_IN_CODE_TTL.ago &&
      sign_in_code_attempts < MAX_SIGN_IN_ATTEMPTS
  end

  def verify_sign_in_code(code)
    return false unless sign_in_code_usable?

    increment!(:sign_in_code_attempts)
    if ActiveSupport::SecurityUtils.secure_compare(sign_in_code_digest, digest(code.to_s.gsub(/\D/, "")))
      update!(sign_in_code_digest: nil, joined_at: joined_at || Time.current)
    else
      false
    end
  end

  private
    def digest(code)
      OpenSSL::HMAC.hexdigest("SHA256", Rails.application.secret_key_base, "#{id}:#{code}")
    end
end
