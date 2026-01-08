import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "image",
    "counter",
    "playButton",
    "speed",
    "speedLabel",
    "stage",
    "controls",
    "fullscreenButton",
    "fullscreenHint",
    "loading",
    "error",
    "errorText",
  ]

  static values = {
    slides: Array,
    slidesUrl: String,
    intervalMs: Number,
  }

  async connect() {
    this.index = 0
    this.playing = false
    this.timer = null
    this.hintTimer = null

    this.boundKeydown = (e) => this.onKeydown(e)
    this.boundFullscreenChange = () => this.onFullscreenChange()
    window.addEventListener("keydown", this.boundKeydown)
    document.addEventListener("fullscreenchange", this.boundFullscreenChange)

    this.renderCounter()
    this.renderSpeedLabelFromInterval()
    this.renderFullscreenButton()

    await this.loadSlides()
  }

  disconnect() {
    this.stopTimer()
    this.clearHintTimer()
    window.removeEventListener("keydown", this.boundKeydown)
    document.removeEventListener("fullscreenchange", this.boundFullscreenChange)
  }

  togglePlay() {
    if (this.playing) this.pause()
    else this.play()
  }

  play() {
    if (!this.hasSlides()) return
    if (this.playing) return
    this.playing = true
    this.renderPlayButton()
    this.startTimer()
  }

  pause() {
    if (!this.playing) return
    this.playing = false
    this.renderPlayButton()
    this.stopTimer()
  }

  next() {
    if (!this.hasSlides()) return
    const nextIndex = (this.index + 1) % this.slidesValue.length
    this.show(nextIndex)
  }

  prev() {
    if (!this.hasSlides()) return
    const len = this.slidesValue.length
    const prevIndex = (this.index - 1 + len) % len
    this.show(prevIndex)
  }

  speedChanged(event) {
    const seconds = parseFloat(event.target.value)
    if (!Number.isFinite(seconds) || seconds <= 0) return

    this.intervalMsValue = Math.round(seconds * 1000)
    this.renderSpeedLabel(seconds)

    if (this.playing) this.startTimer()
  }

  show(newIndex) {
    const slide = this.slidesValue[newIndex]
    if (!slide) return

    this.index = newIndex
    if (slide.url) this.imageTarget.src = slide.url

    this.renderCounter()
    this.preloadNext()
  }

  async loadSlides() {
    this.hideError()
    this.showLoading()

    try {
      if (!this.hasSlidesUrlValue || !this.slidesUrlValue) throw new Error("slidesUrl missing")

      const response = await fetch(this.slidesUrlValue, {
        headers: { Accept: "application/json" },
        credentials: "same-origin",
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()
      const slides = Array.isArray(data?.slides) ? data.slides : []
      this.slidesValue = slides

      if (this.hasSlides()) this.show(0)
    } catch (e) {
      this.showError(`Failed to load slideshow (${e?.message || "unknown error"}).`)
    } finally {
      this.hideLoading()
    }
  }

  async toggleFullscreen() {
    if (!this.hasStageTarget) return

    if (document.fullscreenElement) await document.exitFullscreen()
    else await this.stageTarget.requestFullscreen()
  }

  // --- internals ---

  hasSlides() {
    return Array.isArray(this.slidesValue) && this.slidesValue.length > 0
  }

  startTimer() {
    this.stopTimer()
    const interval = this.intervalMsValue || 3000
    this.timer = window.setInterval(() => this.next(), interval)
  }

  stopTimer() {
    if (!this.timer) return
    window.clearInterval(this.timer)
    this.timer = null
  }

  preloadNext() {
    if (!this.hasSlides()) return
    const nextIndex = (this.index + 1) % this.slidesValue.length
    const nextSlide = this.slidesValue[nextIndex]
    if (!nextSlide?.url) return
    const img = new Image()
    img.src = nextSlide.url
  }

  onKeydown(event) {
    const el = document.activeElement
    const tag = el?.tagName?.toLowerCase()
    if (tag === "input" || tag === "textarea" || tag === "select") return

    if (event.key === " ") {
      event.preventDefault()
      this.togglePlay()
      return
    }
    if (event.key === "ArrowRight") {
      event.preventDefault()
      this.next()
      return
    }
    if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.prev()
      return
    }
  }

  onFullscreenChange() {
    if (this.hasControlsTarget) {
      this.controlsTarget.classList.toggle("hidden", this.isStageFullscreen())
    }
    this.renderFullscreenButton()

    if (this.isStageFullscreen()) {
      this.showFullscreenHint()
      if (this.hasStageTarget) this.stageTarget.focus()
    } else {
      this.hideFullscreenHint()
    }
  }

  isStageFullscreen() {
    return this.hasStageTarget && document.fullscreenElement === this.stageTarget
  }

  renderFullscreenButton() {
    if (!this.hasFullscreenButtonTarget) return
    this.fullscreenButtonTarget.textContent = document.fullscreenElement ? "Exit fullscreen" : "Fullscreen"
  }

  showFullscreenHint() {
    if (!this.hasFullscreenHintTarget) return
    this.fullscreenHintTarget.classList.remove("hidden")
    this.clearHintTimer()
    this.hintTimer = window.setTimeout(() => this.hideFullscreenHint(), 1500)
  }

  hideFullscreenHint() {
    if (!this.hasFullscreenHintTarget) return
    this.fullscreenHintTarget.classList.add("hidden")
    this.clearHintTimer()
  }

  clearHintTimer() {
    if (!this.hintTimer) return
    window.clearTimeout(this.hintTimer)
    this.hintTimer = null
  }

  renderCounter() {
    if (!this.hasCounterTarget) return
    const total = this.slidesValue?.length || 0
    this.counterTarget.textContent = total ? `${this.index + 1} / ${total}` : ""
  }

  renderPlayButton() {
    if (!this.hasPlayButtonTarget) return
    this.playButtonTarget.textContent = this.playing ? "Pause" : "Play"
  }

  renderSpeedLabelFromInterval() {
    if (!this.hasSpeedLabelTarget) return
    const seconds = ((this.intervalMsValue || 3000) / 1000).toFixed(1)
    this.speedLabelTarget.textContent = `${seconds}s`
  }

  renderSpeedLabel(seconds) {
    if (!this.hasSpeedLabelTarget) return
    this.speedLabelTarget.textContent = `${seconds.toFixed(1)}s`
  }

  showLoading() {
    if (!this.hasLoadingTarget) return
    this.loadingTarget.classList.remove("hidden")
  }

  hideLoading() {
    if (!this.hasLoadingTarget) return
    this.loadingTarget.classList.add("hidden")
  }

  showError(message) {
    if (this.hasErrorTextTarget) this.errorTextTarget.textContent = message
    if (this.hasErrorTarget) this.errorTarget.classList.remove("hidden")
  }

  hideError() {
    if (this.hasErrorTarget) this.errorTarget.classList.add("hidden")
  }
}
