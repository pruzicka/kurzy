import { Controller } from "@hotwired/stimulus"

// Marks a segment as completed when the video finishes (ended event).
// Applies returned Turbo Streams to update the sidebar progress.
export default class extends Controller {
  static values = {
    completeUrl: String,
    completed: Boolean,
  }

  static targets = ["continue"]

  connect() {
    if (this.completedValue) return
    this.disableContinue()
  }

  complete() {
    if (this.completedValue) return
    this.completedValue = true
    this.enableContinue()

    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch(this.completeUrlValue, {
      method: "POST",
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": token,
      },
      credentials: "same-origin",
    })
      .then((r) => r.text())
      .then((html) => {
        if (window.Turbo?.renderStreamMessage) window.Turbo.renderStreamMessage(html)
      })
      .catch(() => {
        // Non-fatal; sidebar progress can update on next navigation.
      })
  }

  disableContinue() {
    if (!this.hasContinueTarget) return
    this.continueTarget.classList.add("pointer-events-none", "opacity-60")
    this.continueTarget.setAttribute("aria-disabled", "true")
  }

  enableContinue() {
    if (!this.hasContinueTarget) return
    this.continueTarget.classList.remove("pointer-events-none", "opacity-60")
    this.continueTarget.removeAttribute("aria-disabled")
  }
}

