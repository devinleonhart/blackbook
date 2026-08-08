import { Controller } from "@hotwired/stimulus"

const SPEED_STORAGE_KEY = "bb-slideshow-speed"

export default class extends Controller {
  static targets = [
    "layerA",
    "layerB",
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
    "progress",
    "favoriteButton",
    "detailLink",
    "character",
  ]

  static values = {
    slidesUrl: String,
    intervalMs: Number,
  }

  async connect() {
    this.index = 0
    this.slides = [] // runtime-only state, populated by loadSlides()
    this.playing = false
    this.timer = null
    this.hintTimer = null
    this.pseudoFullscreen = false
    this.progressAnim = null

    // Crossfade layers: front is visible, back receives the next image.
    this.frontLayer = this.hasLayerATarget ? this.layerATarget : null
    this.backLayer = this.hasLayerBTarget ? this.layerBTarget : null

    this.restoreSpeed()

    this.boundKeydown = (e) => this.onKeydown(e)
    this.boundFullscreenChange = () => this.onFullscreenChange()
    window.addEventListener("keydown", this.boundKeydown)
    document.addEventListener("fullscreenchange", this.boundFullscreenChange)
    document.addEventListener("webkitfullscreenchange", this.boundFullscreenChange)
    document.addEventListener("mozfullscreenchange", this.boundFullscreenChange)
    document.addEventListener("MSFullscreenChange", this.boundFullscreenChange)

    this.renderCounter()
    this.renderSpeedLabelFromInterval()
    this.renderFullscreenButton()

    await this.loadSlides()
  }

  disconnect() {
    this.stopTimer()
    this.stopProgress()
    this.clearHintTimer()
    this.exitPseudoFullscreen()
    window.removeEventListener("keydown", this.boundKeydown)
    document.removeEventListener("fullscreenchange", this.boundFullscreenChange)
    document.removeEventListener("webkitfullscreenchange", this.boundFullscreenChange)
    document.removeEventListener("mozfullscreenchange", this.boundFullscreenChange)
    document.removeEventListener("MSFullscreenChange", this.boundFullscreenChange)
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
    this.startProgress()
  }

  pause() {
    if (!this.playing) return
    this.playing = false
    this.renderPlayButton()
    this.stopTimer()
    this.stopProgress()
  }

  next() {
    if (!this.hasSlides()) return
    const nextIndex = (this.index + 1) % this.slides.length
    this.show(nextIndex)
    if (this.playing) this.startTimer()
  }

  prev() {
    if (!this.hasSlides()) return
    const len = this.slides.length
    const prevIndex = (this.index - 1 + len) % len
    this.show(prevIndex)
    if (this.playing) this.startTimer()
  }

  speedChanged(event) {
    const seconds = parseFloat(event.target.value)
    if (!Number.isFinite(seconds) || seconds <= 0) return

    this.intervalMsValue = Math.round(seconds * 1000)
    this.renderSpeedLabel(seconds)
    this.persistSpeed(seconds)

    if (this.playing) {
      this.startTimer()
      this.startProgress()
    }
  }

  show(newIndex) {
    const slide = this.slides[newIndex]
    if (!slide) return

    this.index = newIndex
    this.crossfadeTo(slide)

    this.renderCounter()
    this.renderFavoriteButton()
    this.renderDetailLink()
    this.preloadNext()

    if (this.playing) this.startProgress()
    else this.stopProgress()
  }

  crossfadeTo(slide) {
    if (!this.frontLayer || !this.backLayer) return
    if (!slide.url) return

    const incoming = this.backLayer
    const outgoing = this.frontLayer

    const swap = () => {
      incoming.classList.add("bb-slideshow-layer--front")
      outgoing.classList.remove("bb-slideshow-layer--front")
      incoming.setAttribute("alt", slide.characters?.length ? slide.characters.join(", ") : "Slideshow image")
      incoming.removeAttribute("aria-hidden")
      outgoing.setAttribute("alt", "")
      outgoing.setAttribute("aria-hidden", "true")
      this.frontLayer = incoming
      this.backLayer = outgoing
    }

    incoming.src = slide.url
    if (incoming.decode) incoming.decode().then(swap).catch(swap)
    else swap()
  }

  async loadSlides() {
    this.hideError()
    this.showLoading()
    this.pause()

    try {
      if (!this.hasSlidesUrlValue || !this.slidesUrlValue) throw new Error("slidesUrl missing")

      const response = await fetch(this.slidesUrlValue, {
        headers: { Accept: "application/json" },
        credentials: "same-origin",
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const data = await response.json()
      const slides = Array.isArray(data?.slides) ? data.slides : []
      this.slides = slides
      this.index = 0

      if (this.hasSlides()) this.show(0)
      else this.renderCounter()
    } catch (e) {
      this.showError(`Failed to load slideshow (${e?.message || "unknown error"}).`)
    } finally {
      this.hideLoading()
    }
  }

  // --- Character filter ---------------------------------------------------

  characterChanged() {
    this.applyCharacterFilter(this.selectedCharacterIds())
  }

  clearCharacters() {
    if (this.hasCharacterTarget) this.characterTargets.forEach((el) => { el.checked = false })
    this.applyCharacterFilter([])
  }

  selectedCharacterIds() {
    if (!this.hasCharacterTarget) return []
    return this.characterTargets.filter((el) => el.checked).map((el) => el.value)
  }

  applyCharacterFilter(ids) {
    // Rebuild the JSON endpoint URL, preserving mode/universe, and reload slides.
    const slidesUrl = new URL(this.slidesUrlValue, window.location.origin)
    slidesUrl.searchParams.delete("character_ids[]")
    ids.forEach((id) => slidesUrl.searchParams.append("character_ids[]", id))
    this.slidesUrlValue = slidesUrl.pathname + slidesUrl.search

    // Mirror the selection in the page URL so a reload remembers it.
    const pageUrl = new URL(window.location.href)
    pageUrl.searchParams.delete("character_ids[]")
    ids.forEach((id) => pageUrl.searchParams.append("character_ids[]", id))
    window.history.replaceState({}, "", pageUrl.pathname + pageUrl.search)

    this.loadSlides()
  }

  // --- Per-slide actions --------------------------------------------------

  async toggleFavorite() {
    const slide = this.slides[this.index]
    if (!slide?.favorite_url) return

    const desired = !slide.favorited
    try {
      const response = await fetch(slide.favorite_url, {
        method: "PATCH",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-Token": this.csrfToken(),
        },
        credentials: "same-origin",
        body: `image[favorite]=${desired}`,
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      const data = await response.json()
      slide.favorited = Boolean(data?.favorited)
      this.renderFavoriteButton()
    } catch (e) {
      this.showError(`Couldn't update favorite (${e?.message || "unknown error"}).`)
    }
  }

  openDetail() {
    const slide = this.slides[this.index]
    if (!slide?.detail_url) return
    window.open(slide.detail_url, "_blank", "noopener")
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }

  // --- Fullscreen ---------------------------------------------------------

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

  // Click zones: left third = prev, right third = next. The centre toggles play,
  // except in fullscreen where it exits (so touch devices without Esc can leave).
  stageTapped(event) {
    if (event?.target?.closest?.("a,button,input,label")) return

    const rect = this.stageTarget.getBoundingClientRect()
    const x = (event.clientX - rect.left) / rect.width

    if (x < 0.33) {
      this.prev()
      return
    }
    if (x > 0.67) {
      this.next()
      return
    }

    if (this.pseudoFullscreen) {
      this.exitPseudoFullscreen()
      return
    }
    if (this.currentFullscreenElement()) {
      this.exitFullscreen().catch(() => {})
      return
    }
    this.togglePlay()
  }

  // Private methods

  hasSlides() {
    return Array.isArray(this.slides) && this.slides.length > 0
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

  startProgress() {
    this.stopProgress()
    if (!this.hasProgressTarget || !this.progressTarget.animate) return
    const duration = this.intervalMsValue || 3000
    this.progressAnim = this.progressTarget.animate(
      [{ transform: "scaleX(0)" }, { transform: "scaleX(1)" }],
      { duration, easing: "linear", fill: "forwards" },
    )
  }

  stopProgress() {
    if (!this.progressAnim) return
    this.progressAnim.cancel()
    this.progressAnim = null
  }

  preloadNext() {
    if (!this.hasSlides()) return
    const nextIndex = (this.index + 1) % this.slides.length
    const nextSlide = this.slides[nextIndex]
    if (!nextSlide?.url) return
    const img = new Image()
    img.src = nextSlide.url
  }

  onKeydown(event) {
    const el = document.activeElement
    const tag = el?.tagName?.toLowerCase()
    if (tag === "input" || tag === "textarea" || tag === "select") return

    switch (event.key) {
      case " ":
        event.preventDefault()
        this.togglePlay()
        break
      case "ArrowRight":
        event.preventDefault()
        this.next()
        break
      case "ArrowLeft":
        event.preventDefault()
        this.prev()
        break
      case "f":
      case "F":
        event.preventDefault()
        this.toggleFavorite()
        break
      case "o":
      case "O":
        event.preventDefault()
        this.openDetail()
        break
      default:
        break
    }
  }

  onFullscreenChange() {
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

  renderFavoriteButton() {
    if (!this.hasFavoriteButtonTarget) return
    const slide = this.slides[this.index]
    const favorited = Boolean(slide?.favorited)
    this.favoriteButtonTarget.textContent = favorited ? "★ Favorited" : "☆ Favorite"
    this.favoriteButtonTarget.classList.toggle("bb-btn-primary", favorited)
    this.favoriteButtonTarget.classList.toggle("bb-btn-outline", !favorited)
  }

  renderDetailLink() {
    if (!this.hasDetailLinkTarget) return
    const slide = this.slides[this.index]
    if (slide?.detail_url) this.detailLinkTarget.setAttribute("href", slide.detail_url)
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
    const total = this.slides?.length || 0
    this.counterTarget.textContent = total ? `${this.index + 1} / ${total}` : "0 / 0"
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

  restoreSpeed() {
    let seconds = null
    try {
      seconds = parseFloat(window.localStorage.getItem(SPEED_STORAGE_KEY))
    } catch (e) {
      seconds = null
    }
    if (!Number.isFinite(seconds) || seconds <= 0) return

    this.intervalMsValue = Math.round(seconds * 1000)
    if (this.hasSpeedTarget) this.speedTarget.value = String(seconds)
  }

  persistSpeed(seconds) {
    try {
      window.localStorage.setItem(SPEED_STORAGE_KEY, String(seconds))
    } catch (e) {
      // Ignore storage failures (private mode, quota, etc.).
    }
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

  enterPseudoFullscreen() {
    if (this.pseudoFullscreen) return
    this.pseudoFullscreen = true

    document.documentElement.classList.add("bb-no-scroll")
    document.body.classList.add("bb-no-scroll")

    // Sizing is handled entirely by CSS (100dvh + flex), so no inline styles are
    // written here — that keeps the strict CSP happy and works on iOS Safari.
    this.element.classList.add("bb-slideshow-shell--pseudo")
    this.stageTarget.classList.add("bb-slideshow-stage--pseudo")
    this.stageTarget.classList.remove("bb-slideshow-stage--default")

    if (this.hasTopControlsTarget) this.topControlsTarget.classList.add("hidden")
    if (this.hasBottomControlsTarget) this.bottomControlsTarget.classList.add("hidden")

    this.showFullscreenHint()
    this.renderFullscreenButton()
    if (this.hasStageTarget) this.stageTarget.focus()
  }

  exitPseudoFullscreen() {
    if (!this.pseudoFullscreen) return
    this.pseudoFullscreen = false

    document.documentElement.classList.remove("bb-no-scroll")
    document.body.classList.remove("bb-no-scroll")

    this.element.classList.remove("bb-slideshow-shell--pseudo")
    if (this.hasStageTarget) {
      this.stageTarget.classList.remove("bb-slideshow-stage--pseudo")
      this.stageTarget.classList.add("bb-slideshow-stage--default")
    }

    if (this.hasTopControlsTarget) this.topControlsTarget.classList.remove("hidden")
    if (this.hasBottomControlsTarget) this.bottomControlsTarget.classList.remove("hidden")

    this.hideFullscreenHint()
    this.renderFullscreenButton()
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
