import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error", "fileList", "label"]
  static MAX_FILES = 3

  connect() {
    // Track selected files across multiple selections
    this.selectedFiles = []
  }

  validateFiles(event) {
    const newFiles = Array.from(event.target.files)
    
    // Clear previous error
    this.errorTarget.classList.add("hidden")
    this.errorTarget.textContent = ""
    
    // Combine new files with existing selected files
    const totalFiles = [...this.selectedFiles, ...newFiles]
    
    // Check file count (total including previously selected)
    if (totalFiles.length > this.constructor.MAX_FILES) {
      this.errorTarget.textContent = `You can only upload a maximum of ${this.constructor.MAX_FILES} photos. You have ${this.selectedFiles.length} selected. Please select ${this.constructor.MAX_FILES - this.selectedFiles.length} or fewer files.`
      this.errorTarget.classList.remove("hidden")
      
      // Clear only the input (keep previously selected files)
      event.target.value = ""
      this.updateDisplay()
      return false
    }
    
    // Add new files to selected files
    this.selectedFiles = totalFiles
    
    // Create a DataTransfer object to update the input with all selected files
    const dataTransfer = new DataTransfer()
    this.selectedFiles.forEach(file => {
      dataTransfer.items.add(file)
    })
    this.inputTarget.files = dataTransfer.files
    
    // Update display
    this.updateDisplay()
    
    // Reset the input so user can select more files
    event.target.value = ""
    
    return true
  }

  updateDisplay() {
    if (this.selectedFiles.length > 0) {
      this.labelTarget.textContent = `${this.selectedFiles.length} photo${this.selectedFiles.length > 1 ? 's' : ''} selected`
      
      // Show file list with remove buttons
      const fileListHTML = this.selectedFiles.map((file, index) => {
        return `
          <div class="flex items-center justify-between bg-gray-50 px-3 py-2 rounded mb-1">
            <span class="text-xs text-gray-700 flex-1 truncate">${file.name}</span>
            <button type="button" 
                    data-action="click->photo-upload#removeFile"
                    data-file-index="${index}"
                    class="ml-2 text-red-600 hover:text-red-800 text-xs font-semibold">
              ✕
            </button>
          </div>
        `
      }).join('')
      
      this.fileListTarget.innerHTML = fileListHTML
    } else {
      this.labelTarget.textContent = "Click to upload photos"
      this.fileListTarget.innerHTML = ""
    }
  }

  removeFile(event) {
    const index = parseInt(event.currentTarget.dataset.fileIndex)
    this.selectedFiles.splice(index, 1)
    
    // Update the file input
    const dataTransfer = new DataTransfer()
    this.selectedFiles.forEach(file => {
      dataTransfer.items.add(file)
    })
    this.inputTarget.files = dataTransfer.files
    
    // Update display
    this.updateDisplay()
    
    // Clear error if any
    this.errorTarget.classList.add("hidden")
    this.errorTarget.textContent = ""
  }
}

