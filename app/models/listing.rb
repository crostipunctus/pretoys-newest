class Listing < ApplicationRecord
  # Label and lacquer color for each category.
  CATEGORIES = {
    "baby" => [ "Baby & toddler", "turmeric" ],
    "building" => [ "Blocks & building", "red" ],
    "puzzles" => [ "Puzzles & games", "indigo" ],
    "books" => [ "Books", "leaf" ],
    "pretend" => [ "Pretend play", "red" ],
    "vehicles" => [ "Cars & trains", "indigo" ],
    "outdoor" => [ "Outdoor & ride-ons", "leaf" ],
    "arts" => [ "Arts & crafts", "turmeric" ],
    "learning" => [ "Science & learning", "indigo" ],
    "other" => [ "Other", "wood" ]
  }.freeze

  AGE_GROUPS = {
    "0-1" => "0–12 months",
    "1-3" => "1–3 years",
    "3-5" => "3–5 years",
    "5-8" => "5–8 years",
    "8+" => "8+ years"
  }.freeze

  CONDITIONS = {
    "unused" => "New / unused",
    "like_new" => "Like new",
    "good" => "Good",
    "well_loved" => "Well loved"
  }.freeze

  MAX_PHOTOS = 6

  belongs_to :member

  has_many_attached :photos do |attachable|
    attachable.variant :thumb, resize_to_fill: [ 480, 480 ]
    attachable.variant :large, resize_to_limit: [ 1200, 1200 ]
  end

  enum :status, { available: "available", reserved: "reserved", given_away: "given_away" }, validate: true

  normalizes :title, :neighborhood, with: ->(value) { value.squish.presence }

  validates :title, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 2000 }
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than: 1_000_000 }
  validates :category, inclusion: { in: CATEGORIES.keys }
  validates :age_group, inclusion: { in: AGE_GROUPS.keys }, allow_blank: true
  validates :condition, inclusion: { in: CONDITIONS.keys }
  validate :photos_are_images

  before_create { self.token ||= SecureRandom.alphanumeric(10) }

  scope :visible, -> { where(status: %w[available reserved]) }
  scope :newest_first, -> { order(created_at: :desc) }
  scope :free, -> { where(price: 0) }
  scope :search, ->(query) {
    pattern = "%#{sanitize_sql_like(query.strip)}%"
    where("title LIKE :pattern OR description LIKE :pattern", pattern: pattern)
  }

  # Listing URLs get shared to WhatsApp, so use a token rather than a guessable id.
  def to_param
    token
  end

  def free?
    price.zero?
  end

  def category_label = CATEGORIES.dig(category, 0)
  def category_tone = CATEGORIES.dig(category, 1) || "wood"
  def age_label = AGE_GROUPS[age_group]
  def condition_label = CONDITIONS[condition]

  def status_label
    { "available" => "Available", "reserved" => "Reserved", "given_away" => "Gone" }[status]
  end

  private
    def photos_are_images
      errors.add(:photos, "can have at most #{MAX_PHOTOS} pictures") if photos.size > MAX_PHOTOS
      errors.add(:photos, "must be images") unless photos.all? { |photo| photo.content_type.to_s.start_with?("image/") }
    end
end
