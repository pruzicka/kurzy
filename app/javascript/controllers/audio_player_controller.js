import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["audio", "playBtn", "progress", "progressBar", "currentTime", "duration"]

  connect() {
    this.dragging = false

    this.audioTarget.addEventListener("loadedmetadata", () => {
      this.updateDuration()
    })

    this.audioTarget.addEventListener("durationchange", () => {
      this.updateDuration()
    })

    this.audioTarget.addEventListener("timeupdate", () => {
      this.updateDuration()
      if (this.dragging) return
      this.updateProgress()
    })

    this.audioTarget.addEventListener("ended", () => {
      this.playBtnTarget.innerHTML = this.playIcon
    })

    // Drag-to-seek on progress bar
    this.progressBarTarget.addEventListener("mousedown", (e) => this.startDrag(e))
    this.progressBarTarget.addEventListener("touchstart", (e) => this.startDrag(e), { passive: false })

    this.boundDrag = (e) => this.onDrag(e)
    this.boundStopDrag = (e) => this.stopDrag(e)
  }

  toggle() {
    if (this.audioTarget.paused) {
      this.audioTarget.play()
      this.playBtnTarget.innerHTML = this.pauseIcon
    } else {
      this.audioTarget.pause()
      this.playBtnTarget.innerHTML = this.playIcon
    }
  }

  skip(e) {
    const seconds = parseInt(e.params.seconds)
    this.audioTarget.currentTime = Math.max(0, Math.min(this.audioTarget.duration, this.audioTarget.currentTime + seconds))
  }

  seek(e) {
    const rect = this.progressBarTarget.getBoundingClientRect()
    const ratio = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width))
    this.audioTarget.currentTime = ratio * this.audioTarget.duration
    this.updateProgress()
  }

  startDrag(e) {
    this.dragging = true
    if (e.type === "touchstart") e.preventDefault()
    document.addEventListener("mousemove", this.boundDrag)
    document.addEventListener("mouseup", this.boundStopDrag)
    document.addEventListener("touchmove", this.boundDrag, { passive: false })
    document.addEventListener("touchend", this.boundStopDrag)
    this.onDrag(e)
  }

  onDrag(e) {
    if (!this.dragging) return
    const clientX = e.touches ? e.touches[0].clientX : e.clientX
    const rect = this.progressBarTarget.getBoundingClientRect()
    const ratio = Math.max(0, Math.min(1, (clientX - rect.left) / rect.width))
    this.progressTarget.style.width = `${ratio * 100}%`
    this.currentTimeTarget.textContent = this.formatTime(ratio * this.audioTarget.duration)
  }

  stopDrag(e) {
    if (!this.dragging) return
    const clientX = e.changedTouches ? e.changedTouches[0].clientX : e.clientX
    const rect = this.progressBarTarget.getBoundingClientRect()
    const ratio = Math.max(0, Math.min(1, (clientX - rect.left) / rect.width))
    this.audioTarget.currentTime = ratio * this.audioTarget.duration
    this.dragging = false
    document.removeEventListener("mousemove", this.boundDrag)
    document.removeEventListener("mouseup", this.boundStopDrag)
    document.removeEventListener("touchmove", this.boundDrag)
    document.removeEventListener("touchend", this.boundStopDrag)
  }

  updateDuration() {
    const duration = this.audioTarget.duration
    if (duration && isFinite(duration)) {
      this.durationTarget.textContent = this.formatTime(duration)
    }
  }

  updateProgress() {
    const { currentTime, duration } = this.audioTarget
    if (!duration || !isFinite(duration)) return
    this.progressTarget.style.width = `${(currentTime / duration) * 100}%`
    this.currentTimeTarget.textContent = this.formatTime(currentTime)
  }

  formatTime(sec) {
    const m = Math.floor(sec / 60)
    const s = Math.floor(sec % 60)
    return `${m}:${s.toString().padStart(2, "0")}`
  }

  get playIcon() {
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6"><path fill-rule="evenodd" d="M4.5 5.653c0-1.427 1.529-2.33 2.779-1.643l11.54 6.347c1.295.712 1.295 2.573 0 3.286L7.28 19.99c-1.25.687-2.779-.217-2.779-1.643V5.653Z" clip-rule="evenodd" /></svg>`
  }

  get pauseIcon() {
    return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="size-6"><path fill-rule="evenodd" d="M6.75 5.25a.75.75 0 0 1 .75.75v12a.75.75 0 0 1-1.5 0V6a.75.75 0 0 1 .75-.75Zm10.5 0a.75.75 0 0 1 .75.75v12a.75.75 0 0 1-1.5 0V6a.75.75 0 0 1 .75-.75Z" clip-rule="evenodd" /></svg>`
  }
}
