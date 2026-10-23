import { Controller } from "@hotwired/stimulus"

// Shows thumbnails of the photos picked in a file input before upload.
export default class extends Controller {
  static targets = ["input", "previews"]

  show() {
    this.previewsTarget.replaceChildren()

    for (const file of this.inputTarget.files) {
      const img = document.createElement("img")
      img.src = URL.createObjectURL(file)
      img.alt = ""
      img.onload = () => URL.revokeObjectURL(img.src)

      const thumb = document.createElement("span")
      thumb.className = "photo-thumb"
      thumb.append(img)
      this.previewsTarget.append(thumb)
    }
  }
}
