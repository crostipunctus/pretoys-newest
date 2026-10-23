# Pretoys

A private second-hand toy marketplace for a moms' WhatsApp group. It borrows the
group's trust: the first members are imported straight from the group, and anyone
new must be vouched for by an existing member.

## How it works

- **Invite-only sign-in.** Members sign in with their WhatsApp number and a 6-digit
  code. Numbers that aren't in the circle are turned away.
- **Founding members** come from the WhatsApp group: an admin pastes the group's
  numbers (or a chat export) on *Circle → Import from WhatsApp group*.
- **Vouching.** Any member can invite a mom they know. The invitee's profile shows
  "Invited by …", so every member traces back to the group.
- **Listings** have photos, price (0 = free), category, age range, condition and
  pickup area. Sellers mark them reserved or gone.
- **WhatsApp does the rest.** "Message on WhatsApp" opens a chat with the seller,
  pre-filled with the listing. "Share in the WhatsApp group" posts the link, which
  shows a preview card even to signed-out viewers (title, price, photo only).

## Running locally

```
bin/setup        # installs gems, prepares and seeds the database
bin/rails server
```

Sign in with `99000 00001` (the seeded admin). In development the sign-in code
appears on the code screen and in the log.

## Going live

1. Create the first admin: `bin/rails circle:admin PHONE=+919876543210 NAME="Your name"`
2. Configure code delivery (Twilio):
   - `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`
   - `TWILIO_FROM`: an SMS number, or `whatsapp:+1…` for a Twilio WhatsApp sender
     (WhatsApp needs an approved message template outside the sandbox).
3. Optional: `DEFAULT_COUNTRY_CODE` (default `91`) and `CURRENCY_SYMBOL` (default `₹`).
4. Sign in, import the group's numbers, then post the site link in the group.

Deployment is set up for Kamal (`config/deploy.yml`). Photos are stored on local
disk by default; point Active Storage at S3 or similar for production.

## Logo

The wordmark is real 3D: letters built from lathe-turned, lacquered wooden pieces in the
style of Channapatna toys, rendered with three.js in the browser (no Blender needed).
`design/logo/directions.html` shows the three directions that were considered.

To tweak colors or shapes, edit `design/logo/concepts.html`, then:

```
python3 design/logo/render_server.py
```

Open http://localhost:8765/concepts.html?style=lacquer&shadow=0 and run `await saveRender()`
in the console. `&word=p&w=1024&h=1024` renders the app icon's letter, and leaving out
`shadow=0` adds the soft wall shadow used on the link-preview image. Renders land in
`design/logo/out/`; convert them with ImageMagick into `app/assets/images/pretoys-logo.{webp,png}`,
`public/icon.png`, `public/apple-touch-icon.png`, `public/favicon.ico` and `public/og-image.jpg`.

## Tests

```
bin/rails test
```
