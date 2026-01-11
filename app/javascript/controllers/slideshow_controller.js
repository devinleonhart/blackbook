import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "image",
    "counter",
    "playButton",
    "speed",
    "speedLabel",
    "stage",
    "topControls",
    "bottomControls",
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
    this.pseudoFullscreen = false

    this.boundKeydown = (e) => this.onKeydown(e)
    this.boundFullscreenChange = () => this.onFullscreenChange()
    this.boundResize = () => this.onResize()
    this.boundOrientationChange = () => this.onResize()
    window.addEventListener("keydown", this.boundKeydown)
    document.addEventListener("fullscreenchange", this.boundFullscreenChange)
    document.addEventListener("webkitfullscreenchange", this.boundFullscreenChange)
    document.addEventListener("mozfullscreenchange", this.boundFullscreenChange)
    document.addEventListener("MSFullscreenChange", this.boundFullscreenChange)
    window.addEventListener("resize", this.boundResize)
    window.addEventListener("orientationchange", this.boundOrientationChange)

    this.renderCounter()
    this.renderSpeedLabelFromInterval()
    this.renderFullscreenButton()

    await this.loadSlides()
  }

  disconnect() {
    this.stopTimer()
    this.clearHintTimer()
    this.exitPseudoFullscreen()
    window.removeEventListener("keydown", this.boundKeydown)
    document.removeEventListener("fullscreenchange", this.boundFullscreenChange)
    document.removeEventListener("webkitfullscreenchange", this.boundFullscreenChange)
    document.removeEventListener("mozfullscreenchange", this.boundFullscreenChange)
    document.removeEventListener("MSFullscreenChange", this.boundFullscreenChange)
    window.removeEventListener("resize", this.boundResize)
    window.removeEventListener("orientationchange", this.boundOrientationChange)
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

  async toggleFullscreen(event) {
    event?.preventDefault?.()
    if (!this.hasStageTarget) return

    try {
      if (this.pseudoFullscreen) {
        this.exitPseudoFullscreen()
        return
      }

      if (this.currentFullscreenElement()) {
        await this.exitFullscreen()
      } else {
        await this.requestFullscreen(this.stageTarget)
      }
    } catch (e) {
      this.enterPseudoFullscreen()
    }
  }

  stageTapped(event) {
    if (!this.pseudoFullscreen && !this.currentFullscreenElement()) return

    if (event?.target?.closest?.("[data-slideshow-target='topControls'],[data-slideshow-target='bottomControls']")) return

    if (this.pseudoFullscreen) {
      this.exitPseudoFullscreen()
      return
    }

    this.exitFullscreen().catch(() => {})
  }

  // Private methods

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
    // In real fullscreen we hide chrome; in pseudo fullscreen we manage that ourselves.
    if (this.hasTopControlsTarget && !this.pseudoFullscreen) {
      const shouldHide = this.isStageFullscreen()
      this.topControlsTarget.classList.toggle("hidden", shouldHide)
      if (this.hasBottomControlsTarget) this.bottomControlsTarget.classList.toggle("hidden", shouldHide)
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
    return this.hasStageTarget && this.currentFullscreenElement() === this.stageTarget
  }

  renderFullscreenButton() {
    if (!this.hasFullscreenButtonTarget) return
    this.fullscreenButtonTarget.textContent =
      this.pseudoFullscreen || this.currentFullscreenElement() ? "Exit fullscreen" : "Fullscreen"
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

  onResize() {
    if (!this.pseudoFullscreen) return
    this.updatePseudoDimensions()
  }

  enterPseudoFullscreen() {
    if (this.pseudoFullscreen) return
    this.pseudoFullscreen = true

    document.documentElement.classList.add("bb-no-scroll")
    document.body.classList.add("bb-no-scroll")

    this.element.classList.add("bb-slideshow-shell--pseudo")
    this.stageTarget.classList.add("bb-slideshow-stage--pseudo")
    this.imageTarget.classList.remove("bb-slideshow-image--default")
    this.imageTarget.classList.add("bb-slideshow-image--pseudo")

    if (this.hasTopControlsTarget) this.topControlsTarget.classList.add("hidden")
    if (this.hasBottomControlsTarget) this.bottomControlsTarget.classList.add("hidden")

    this.updatePseudoDimensions()

    this.showFullscreenHint()
    this.renderFullscreenButton()
    if (this.hasStageTarget) this.stageTarget.focus()
  }

  exitPseudoFullscreen() {
    if (!this.pseudoFullscreen) return
    this.pseudoFullscreen = false

    document.documentElement.classList.remove("bb-no-scroll")
    document.body.classList.remove("bb-no-scroll")

    this.element.style.height = ""
    if (this.hasStageTarget) this.stageTarget.style.height = ""

    this.element.classList.remove("bb-slideshow-shell--pseudo")
    if (this.hasStageTarget) this.stageTarget.classList.remove("bb-slideshow-stage--pseudo")

    if (this.hasImageTarget) {
      this.imageTarget.classList.remove("bb-slideshow-image--pseudo")
      this.imageTarget.classList.add("bb-slideshow-image--default")
    }

    if (this.hasTopControlsTarget) this.topControlsTarget.classList.remove("hidden")
    if (this.hasBottomControlsTarget) this.bottomControlsTarget.classList.remove("hidden")

    this.hideFullscreenHint()
    this.renderFullscreenButton()
  }

  updatePseudoDimensions() {
    if (!this.pseudoFullscreen) return
    if (!this.hasStageTarget) return

    const viewportHeight = window.visualViewport?.height || window.innerHeight
    // Lock to the current viewport height so orientation/address-bar changes resize cleanly.
    this.element.style.height = `${Math.round(viewportHeight)}px`
    this.stageTarget.style.height = `${Math.round(viewportHeight)}px`

    // Force a reflow for mobile browsers when the address bar collapses/expands.
    this.stageTarget.offsetHeight
  }

  currentFullscreenElement() {
    return (
      document.fullscreenElement ||
      document.webkitFullscreenElement ||
      document.mozFullScreenElement ||
      document.msFullscreenElement ||
      null
    )
  }

  exitFullscreen() {
    const fn =
      document.exitFullscreen ||
      document.webkitExitFullscreen ||
      document.mozCancelFullScreen ||
      document.msExitFullscreen
    return fn ? fn.call(document) : Promise.reject(new Error("fullscreen exit unsupported"))
  }

  requestFullscreen(element) {
    const fn =
      element.requestFullscreen ||
      element.webkitRequestFullscreen ||
      element.mozRequestFullScreen ||
      element.msRequestFullscreen
    return fn ? fn.call(element) : Promise.reject(new Error("fullscreen unsupported"))
  }
}
