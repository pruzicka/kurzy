import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "input", "filter", "item", "selectedLink", "selectedEmpty", "clear"]

  open() {
    this.modalTarget.classList.remove("hidden")
    if (this.hasFilterTarget) {
      this.filterTarget.value = ""
      this.filter()
      this.filterTarget.focus()
    }
  }

  close() {
    this.modalTarget.classList.add("hidden")
  }

  select(event) {
    const target = event.currentTarget
    const id = target.dataset.id
    const title = target.dataset.title
    const url = target.dataset.url

    if (this.hasInputTarget) {
      this.inputTarget.value = id
    }

    if (this.hasSelectedLinkTarget) {
      this.selectedLinkTarget.classList.remove("hidden")
      this.selectedLinkTarget.href = url
      this.selectedLinkTarget.textContent = title
    }
    if (this.hasSelectedEmptyTarget) {
      this.selectedEmptyTarget.classList.add("hidden")
    }
    if (this.hasClearTarget) {
      this.clearTarget.classList.remove("hidden")
    }

    this.close()
  }

  clear() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
    }
    if (this.hasSelectedLinkTarget) {
      this.selectedLinkTarget.classList.add("hidden")
      this.selectedLinkTarget.textContent = ""
      this.selectedLinkTarget.removeAttribute("href")
    }
    if (this.hasSelectedEmptyTarget) {
      this.selectedEmptyTarget.classList.remove("hidden")
    }
    if (this.hasClearTarget) {
      this.clearTarget.classList.add("hidden")
    }
  }

  filter() {
    const query = (this.hasFilterTarget ? this.filterTarget.value : "").trim().toLowerCase()
    this.itemTargets.forEach((item) => {
      const title = (item.dataset.title || "").toLowerCase()
      item.classList.toggle("hidden", query.length > 0 && !title.includes(query))
    })
  }
}

