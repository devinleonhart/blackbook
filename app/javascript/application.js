// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// bfcache/Turbo back button can leave native-lazy images stuck unloaded.
function refreshLazyImages() {
  document.querySelectorAll('img[loading="lazy"]').forEach((img) => {
    if (img.complete) return
    const src = img.getAttribute("src")
    if (!src) return
    img.setAttribute("src", src)
  })
}

document.addEventListener("turbo:load", refreshLazyImages)
window.addEventListener("pageshow", (event) => {
  if (event.persisted) refreshLazyImages()
})
