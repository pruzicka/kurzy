import { Controller } from "@hotwired/stimulus"

// Keeps document.title in sync with the hidden #page_title element.
export default class extends Controller {
  connect() {
    this.apply()

    this.observer = new MutationObserver(() => this.apply())
    this.observer.observe(this.element, { childList: true, characterData: true, subtree: true })
  }

  disconnect() {
    this.observer?.disconnect()
  }

  apply() {
    const title = (this.element.textContent || "").trim()
    if (title.length > 0) document.title = title
  }
}

