import { Controller } from "@hotwired/stimulus"

// Lightweight drag & drop enhancement for file inputs.
// Works with Active Storage direct uploads because it only updates the input's FileList.
export default class extends Controller {
  static targets = ["input", "area", "files", "progress"]

  connect() {
    this.refresh()

    // Active Storage direct upload progress events (triggered on the <input>).
    this._onInitialize = (e) => this.onDirectUploadInitialize(e)
    this._onProgress = (e) => this.onDirectUploadProgress(e)
    this._onEnd = (e) => this.onDirectUploadEnd(e)
    this._onError = (e) => this.onDirectUploadError(e)

    this.inputTarget.addEventListener("direct-upload:initialize", this._onInitialize)
    this.inputTarget.addEventListener("direct-upload:progress", this._onProgress)
    this.inputTarget.addEventListener("direct-upload:end", this._onEnd)
    this.inputTarget.addEventListener("direct-upload:error", this._onError)
  }

  disconnect() {
    this.inputTarget.removeEventListener("direct-upload:initialize", this._onInitialize)
    this.inputTarget.removeEventListener("direct-upload:progress", this._onProgress)
    this.inputTarget.removeEventListener("direct-upload:end", this._onEnd)
    this.inputTarget.removeEventListener("direct-upload:error", this._onError)
  }

  open(event) {
    event?.preventDefault()
    event?.stopPropagation()
    // Allow selecting the same file again.
    this.inputTarget.value = null
    this.inputTarget.click()
  }

  changed() {
    this.refresh()
  }

  dragOver(event) {
    event.preventDefault()
    this.areaTarget.classList.add("ring-2", "ring-gray-900/15", "border-gray-300")
  }

  dragLeave(event) {
    event.preventDefault()
    this.areaTarget.classList.remove("ring-2", "ring-gray-900/15", "border-gray-300")
  }

  drop(event) {
    event.preventDefault()
    this.dragLeave(event)

    const dropped = Array.from(event.dataTransfer?.files || [])
    if (dropped.length === 0) return

    const dt = new DataTransfer()
    const allowMultiple = this.inputTarget.multiple
    const files = allowMultiple ? dropped : dropped.slice(0, 1)
    files.forEach((f) => dt.items.add(f))

    this.inputTarget.files = dt.files
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  refresh() {
    if (!this.hasFilesTarget) return

    const files = Array.from(this.inputTarget.files || [])
    if (files.length === 0) {
      this.filesTarget.textContent = ""
      this.areaTarget.classList.remove("border-gray-300", "bg-white")
      return
    }

    const fmt = new Intl.NumberFormat(undefined, { maximumFractionDigits: 1 })
    const toMB = (bytes) => fmt.format(bytes / 1024 / 1024) + " MB"

    this.filesTarget.textContent = files
      .map((f) => `${f.name} (${toMB(f.size)})`)
      .join(allowNewlines(files.length))

    // Make the state obvious even before submit triggers the actual upload.
    this.areaTarget.classList.add("border-gray-300", "bg-white")
  }

  onDirectUploadInitialize(event) {
    if (!this.hasProgressTarget) return
    const { id, file } = event.detail

    const row = document.createElement("div")
    row.dataset.directUploadId = id
    row.className = "rounded-xl border border-gray-200 bg-white px-3 py-2"
    row.innerHTML = `
      <div class="flex items-center justify-between gap-3">
        <div data-dropzone-role="name" class="min-w-0 truncate text-xs font-medium text-gray-900"></div>
        <div data-dropzone-role="label" class="shrink-0 text-[11px] font-medium text-gray-600">0%</div>
      </div>
      <div class="mt-2 h-1.5 w-full overflow-hidden rounded-full bg-gray-100">
        <div data-dropzone-role="bar" class="h-full w-0 bg-gray-900/70"></div>
      </div>
    `

    row.querySelector('[data-dropzone-role="name"]').textContent = file?.name || "Soubor"
    this.progressTarget.appendChild(row)
  }

  onDirectUploadProgress(event) {
    if (!this.hasProgressTarget) return
    const { id, progress } = event.detail
    const row = this.progressTarget.querySelector(`[data-direct-upload-id="${id}"]`)
    if (!row) return

    const pct = Math.max(0, Math.min(100, Math.round(progress || 0)))
    row.querySelector('[data-dropzone-role="label"]').textContent = `${pct}%`
    row.querySelector('[data-dropzone-role="bar"]').style.width = `${pct}%`
  }

  onDirectUploadEnd(event) {
    if (!this.hasProgressTarget) return
    const { id } = event.detail
    const row = this.progressTarget.querySelector(`[data-direct-upload-id="${id}"]`)
    if (!row) return

    row.querySelector('[data-dropzone-role="label"]').textContent = "Hotovo"
    row.querySelector('[data-dropzone-role="bar"]').style.width = "100%"
  }

  onDirectUploadError(event) {
    if (!this.hasProgressTarget) return
    const { id, error } = event.detail
    const row = this.progressTarget.querySelector(`[data-direct-upload-id="${id}"]`)
    if (!row) return

    row.classList.add("border-rose-200", "bg-rose-50")
    row.querySelector('[data-dropzone-role="label"]').textContent = "Chyba"
    if (error) {
      const name = row.querySelector('[data-dropzone-role="name"]')
      name.textContent = `${name.textContent} (${error})`
    }
  }
}

function allowNewlines(count) {
  return count > 1 ? "\n" : ""
}
