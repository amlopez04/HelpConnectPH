import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    notice: String, 
    alert: String 
  }

  connect() {
    // Get a unique identifier for this page load to prevent duplicate toasts
    const pageLoadId = Date.now().toString()
    const lastShownKey = 'last_shown_flash'
    
    // Check if we've already shown this message on this page load
    const lastShown = sessionStorage.getItem(lastShownKey)
    
    // Show toast on page load if flash message exists (only once per session)
    if (this.hasNoticeValue && this.noticeValue && this.noticeValue.trim() !== "") {
      // Only show if we haven't shown a flash message in this session yet
      if (!lastShown || lastShown !== this.noticeValue) {
        this.showToast(this.noticeValue, "success")
        sessionStorage.setItem(lastShownKey, this.noticeValue)
        // Clear the notice after showing to prevent re-display
        this.element.setAttribute('data-toast-notice-value', '')
      }
    }
    
    if (this.hasAlertValue && this.alertValue && this.alertValue.trim() !== "") {
      // Only show if we haven't shown this exact alert message
      if (!lastShown || lastShown !== this.alertValue) {
        this.showToast(this.alertValue, "error")
        sessionStorage.setItem(lastShownKey, this.alertValue)
        // Clear the alert after showing to prevent re-display
        this.element.setAttribute('data-toast-alert-value', '')
      }
    }
  }

  showToast(message, type = "info") {
    // Remove existing toasts
    const existingToasts = document.querySelectorAll(".toast-notification")
    existingToasts.forEach(toast => toast.remove())

    // Create toast element
    const toast = document.createElement("div")
    toast.className = `toast-notification toast-${type}`
    
    const bgColor = type === "success" ? "bg-green-50 border-green-400 text-green-800" : 
                    type === "error" ? "bg-red-50 border-red-400 text-red-800" :
                    "bg-blue-50 border-blue-400 text-blue-800"
    
    toast.innerHTML = `
      <div class="border-l-4 ${type === "success" ? "border-green-400" : type === "error" ? "border-red-400" : "border-blue-400"} ${bgColor} p-4 rounded-lg shadow-lg mb-4 flex items-center justify-between min-w-[300px] max-w-md">
        <div class="flex items-center">
          <div class="flex-shrink-0">
            ${type === "success" ? 
              '<svg class="h-5 w-5 text-green-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"/></svg>' :
              type === "error" ?
              '<svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"/></svg>' :
              '<svg class="h-5 w-5 text-blue-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"/></svg>'
            }
          </div>
          <div class="ml-3">
            <p class="text-sm font-medium">${message}</p>
          </div>
        </div>
        <button onclick="this.parentElement.parentElement.remove()" class="ml-4 text-gray-400 hover:text-gray-600">
          <svg class="h-4 w-4" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/></svg>
        </button>
      </div>
    `
    
    // Add toast to page
    let toastContainer = document.getElementById("toast-container")
    if (!toastContainer) {
      toastContainer = document.createElement("div")
      toastContainer.id = "toast-container"
      toastContainer.className = "fixed top-4 right-4 z-50"
      document.body.appendChild(toastContainer)
    }
    
    toastContainer.appendChild(toast)
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      toast.style.transition = "opacity 0.3s"
      toast.style.opacity = "0"
      setTimeout(() => toast.remove(), 300)
    }, 5000)
  }
}
