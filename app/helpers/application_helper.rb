module ApplicationHelper
  ICONS = {
    "search" => '<circle cx="11" cy="11" r="6.5"/><path d="M20 20l-4.4-4.4"/>',
    "box" => '<path d="M4 8l8-4 8 4v8.5l-8 4-8-4z"/><path d="M4 8l8 4 8-4M12 12v8.5"/>',
    "plus" => '<path d="M12 5v14M5 12h14"/>',
    "rings" => '<circle cx="12" cy="12" r="8.5"/><circle cx="12" cy="12" r="3.5"/>',
    "user" => '<circle cx="12" cy="8" r="4"/><path d="M4.5 20.5c1.4-3.7 4.2-5.6 7.5-5.6s6.1 1.9 7.5 5.6"/>',
    "chat" => '<path d="M4.5 19.5l1.3-3.9A8 8 0 1 1 9 18.6z"/>',
    "share" => '<path d="M12 4v11M7.5 8.5L12 4l4.5 4.5"/><path d="M5 13.5V19h14v-5.5"/>'
  }.freeze

  TONES = %w[ red turmeric leaf indigo ].freeze

  # The 3D lacquered-wood wordmark (rendered from design/logo), WebP with a PNG fallback.
  def logo_tag(**options)
    tag.picture do
      tag.source(srcset: image_path("pretoys-logo.webp"), type: "image/webp") +
        image_tag("pretoys-logo.png", alt: "Pretoys", width: 1200, height: 281, **options)
    end
  end

  def icon(name, css_class: nil)
    tag.svg(ICONS.fetch(name).html_safe, class: [ "icon", css_class ], viewBox: "0 0 24 24", fill: "none",
      stroke: "currentColor", "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round", aria: { hidden: true })
  end

  # A small lacquered bead in one of the palette colors.
  def bead(tone)
    tag.i(class: [ "bead", "tone-#{tone}" ], aria: { hidden: true })
  end

  def price_label(listing)
    listing.free? ? "Free" : "#{Rails.configuration.x.currency_symbol}#{number_with_delimiter(listing.price)}"
  end

  # Opens a WhatsApp chat with one person, message pre-filled.
  def whatsapp_chat_url(phone, text)
    "https://wa.me/#{phone.delete("+")}?text=#{ERB::Util.url_encode(text)}"
  end

  # Opens WhatsApp's chat picker (e.g. to post into the group), message pre-filled.
  def whatsapp_share_url(text)
    "https://wa.me/?text=#{ERB::Util.url_encode(text)}"
  end

  # The first photo, or turned rings in the category's color when there isn't one.
  def listing_cover(listing, variant: :thumb, css_class: "cover")
    if listing.photos.attached?
      image_tag listing.photos.first.variant(variant), alt: listing.title, class: css_class, loading: "lazy"
    else
      tag.div(class: [ css_class, "cover-rings", "tone-#{listing.category_tone}" ], role: "img", aria: { label: listing.category_label })
    end
  end

  # The trust line shown next to a member's name.
  def vouch_line(member)
    if member.whatsapp_group?
      "From the WhatsApp group"
    elsif member.invited_by
      safe_join([ "Invited by ", link_to(member.invited_by.display_name, member.invited_by) ])
    else
      "Invited member"
    end
  end

  def avatar(member, size: :md)
    initials = member.name.to_s.split.first(2).map { |part| part[0] }.join.upcase.presence || "?"
    tag.span(initials, class: [ "avatar", "avatar-#{size}", "tone-#{TONES[member.id.to_i % TONES.size]}" ], aria: { hidden: true })
  end

  def nav_link(label, path, active: current_page?(path))
    link_to label, path, class: [ "nav-link", ("is-active" if active) ], aria: { current: (active ? "page" : nil) }
  end

  def tab_link(label, icon_name, path, active: current_page?(path))
    link_to path, class: [ "tab", ("is-active" if active) ], aria: { current: (active ? "page" : nil) } do
      icon(icon_name) + tag.span(label)
    end
  end
end
