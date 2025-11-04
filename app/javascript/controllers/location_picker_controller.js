import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location-picker"
export default class extends Controller {
  static targets = ["map", "latitude", "longitude", "address", "searchButton"]
  static values = {
    apiKey: String,
    defaultLat: { type: Number, default: 14.4793095 }, // Parañaque City Center (exact coordinates)
    defaultLng: { type: Number, default: 121.0198229 },
    // Strict Parañaque bounding box based on actual city boundaries
    // Center: 14.4793095°N, 121.0198229°E
    // Boundaries tightened to exclude Las Piñas (south), Bacoor (southwest), Taguig (east), Pasay (north)
    north: { type: Number, default: 14.5050 },  // Excludes Pasay/Makati
    south: { type: Number, default: 14.4580 },  // Excludes Las Piñas and Bacoor
    east:  { type: Number, default: 121.0450 }, // Excludes Taguig
    west:  { type: Number, default: 120.9730 }  // Excludes Manila Bay excess area
  }

  connect() {
    // Show loading message while waiting for API
    this.mapTarget.innerHTML = '<div class="p-4 bg-blue-50 text-blue-600 rounded">Loading Google Maps...</div>'
    
    // Check if Google Maps is already loaded
    if (typeof google !== 'undefined' && typeof google.maps !== 'undefined') {
      this.initializeMap()
      return
    }
    
    // Listen for Google Maps loaded event (from callback)
    window.addEventListener('google-maps-loaded', () => {
      this.initializeMap()
    }, { once: true })
    
    // Fallback: wait with retry mechanism (in case event doesn't fire)
    this.waitForGoogleMaps()
  }

  waitForGoogleMaps(maxAttempts = 50, attempt = 0) {
    if (typeof google !== 'undefined' && typeof google.maps !== 'undefined') {
      // API is loaded, initialize map (if not already initialized)
      if (!this.map) {
        this.initializeMap()
      }
      return
    }

    if (attempt >= maxAttempts) {
      // API failed to load after 5 seconds (50 attempts * 100ms)
      console.error('Google Maps API not loaded after waiting')
      this.mapTarget.innerHTML = '<div class="p-4 bg-red-50 text-red-600 rounded">Error: Google Maps API not loaded. Please check your API key and ensure it\'s set correctly in environment variables.</div>'
      return
    }

    // Retry after 100ms
    setTimeout(() => {
      this.waitForGoogleMaps(maxAttempts, attempt + 1)
    }, 100)
  }

  // Haversine distance in meters
  distanceMeters(lat1, lng1, lat2, lng2) {
    const R = 6371000
    const toRad = deg => deg * Math.PI / 180
    const dLat = toRad(lat2 - lat1)
    const dLng = toRad(lng2 - lng1)
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
              Math.sin(dLng/2) * Math.sin(dLng/2)
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    return R * c
  }

  // Shared territory whitelist (approximate centers and radii in meters)
  whitelistZones() {
    return [
      { name: 'NAIA Complex',      lat: 14.5108, lng: 121.0196, radius: 1500 },
      { name: 'Okada Manila',      lat: 14.5157, lng: 120.9845, radius: 600  },
      { name: 'Parqal',            lat: 14.5146, lng: 120.9924, radius: 400  },
      { name: 'Ayala Malls Manila Bay', lat: 14.5171, lng: 120.9916, radius: 450 }
    ]
  }

  isWithinWhitelist(lat, lng) {
    return this.whitelistZones().some(z => this.distanceMeters(lat, lng, z.lat, z.lng) <= z.radius)
  }

  isAllowed(lat, lng) {
    const insideBounds = !(lat > this.northValue || lat < this.southValue || lng > this.eastValue || lng < this.westValue)
    if (insideBounds) return true
    return this.isWithinWhitelist(lat, lng)
  }

  initializeMap() {
    // Default location (Parañaque City Center)
    const center = {
      lat: this.defaultLatValue,
      lng: this.defaultLngValue
    }

    // Tightened Parañaque bounding box to exclude Las Piñas, Taguig, Bacoor, etc.
    // North boundary excludes Pasay/Makati
    // South boundary excludes Las Piñas  
    // East boundary excludes Taguig
    // West boundary excludes Manila Bay (keeps it on land)
    this.bounds = new google.maps.LatLngBounds(
      { lat: this.southValue, lng: this.westValue },
      { lat: this.northValue, lng: this.eastValue }
    )

    // Create the map
    // strictBounds: false allows viewing the full map, but we prevent marker placement outside Parañaque
    this.map = new google.maps.Map(this.mapTarget, {
      center: center,
      zoom: 13,
      mapTypeControl: true,
      streetViewControl: true,
      fullscreenControl: true,
      // No restriction - allow viewing full map, but we'll prevent marker placement outside Parañaque
      // Disable Google Maps default click behavior for places
      clickableIcons: false  // Prevents clicking on POIs (Points of Interest) from placing markers
    })

    // Create a marker
    this.marker = new google.maps.Marker({
      position: center,
      map: this.map,
      draggable: true,
      title: "Drag me to your location!"
    })

    // Add click listener to map (marker can be placed anywhere)
    this.map.addListener('click', (event) => {
      const clickedLocation = event.latLng
      this.placeMarker(clickedLocation)
    })
    
    // Prevent Google Maps from placing its own markers or info windows on outside clicks
    this.map.addListener('rightclick', (event) => {
      // Prevent context menu on right click outside bounds
      if (!this.bounds.contains(event.latLng)) {
        event.stop()
      }
    })

    // Add drag listener to marker (no bounds restriction)
    this.marker.addListener('dragend', (event) => {
      const draggedLocation = event.latLng
      this.updateCoordinates(draggedLocation)
    })

    // Try to get user's current location
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const userLocation = {
            lat: position.coords.latitude,
            lng: position.coords.longitude
          }
          const userLatLng = new google.maps.LatLng(userLocation.lat, userLocation.lng)
          const lat = userLocation.lat
          const lng = userLocation.lng
          
          if (!this.isAllowed(lat, lng)) {
            console.log('❌ GPS location OUTSIDE allowed zones:', lat, lng)
            this.notify("Address must be within Parañaque or approved shared zones (NAIA/Okada/Parqal/Ayala Malls Manila Bay).")
          }
          
          const clamped = this.clampToBounds(userLatLng)
          this.map.setCenter(clamped)
          this.marker.setPosition(clamped)
          this.updateCoordinates(clamped)
        },
        (error) => {
          console.log("Geolocation error:", error)
          // Stay at default location if geolocation fails
        }
      )
    }
  }

  placeMarker(location) {
    // Marker can be placed anywhere; acceptance is validated on submit
    const lat = location.lat()
    const lng = location.lng()

    console.log('✅ APPROVED: Placing marker at:', lat, lng)
    this.marker.setPosition(location)
    this.updateCoordinates(location)
  }

  clampToBounds(latLng) {
    const lat = Math.max(this.southValue, Math.min(this.northValue, latLng.lat()))
    const lng = Math.max(this.westValue, Math.min(this.eastValue, latLng.lng()))
    return new google.maps.LatLng(lat, lng)
  }

  notify(message) {
    try {
      console.log('Showing toast:', message) // Debug log
      
      // Get or create toast container
      let toastContainer = document.getElementById('toast-container')
      if (!toastContainer) {
        console.log('Creating toast container') // Debug log
        toastContainer = document.createElement('div')
        toastContainer.id = 'toast-container'
        toastContainer.className = 'fixed top-4 right-4 z-50'
        toastContainer.style.zIndex = '99999'
        toastContainer.style.pointerEvents = 'none' // Allow clicks through container
        document.body.appendChild(toastContainer)
      }

      // Create toast element
      const toast = document.createElement('div')
      toast.className = 'bg-yellow-600 text-white px-4 py-3 rounded-lg shadow-lg max-w-sm mb-2'
      toast.style.pointerEvents = 'auto' // Enable clicks on toast itself
      toast.style.transition = 'all 0.3s ease-out'
      toast.style.opacity = '0'
      toast.style.transform = 'translateX(100%)'
      toast.innerHTML = `
        <div class="flex items-center justify-between">
          <span class="font-medium text-sm">${message}</span>
          <button onclick="this.parentElement.parentElement.remove()" class="ml-3 text-yellow-200 hover:text-white flex-shrink-0">
            <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
              <path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"/>
            </svg>
          </button>
        </div>
      `

      // Append to container
      toastContainer.appendChild(toast)

      // Force reflow and animate in
      setTimeout(() => {
        toast.style.opacity = '1'
        toast.style.transform = 'translateX(0)'
      }, 10)

      // Auto-remove after 3 seconds
      setTimeout(() => {
        toast.style.opacity = '0'
        toast.style.transform = 'translateX(100%)'
        setTimeout(() => {
          if (toast.parentNode) {
            toast.remove()
          }
        }, 300)
      }, 3000)
    } catch (e) {
      console.error('Toast error:', e)
      console.warn('Location warning:', message)
      // Last resort: alert
      alert(message)
    }
  }

  updateCoordinates(location) {
    // Update hidden latitude/longitude fields
    if (this.hasLatitudeTarget) {
      this.latitudeTarget.value = location.lat()
    }
    if (this.hasLongitudeTarget) {
      this.longitudeTarget.value = location.lng()
    }

    // Reverse geocode to get address
    this.reverseGeocode(location)
  }

  reverseGeocode(location) {
    const geocoder = new google.maps.Geocoder()
    
    geocoder.geocode({ location: location }, (results, status) => {
      if (status === 'OK' && results[0]) {
        if (this.hasAddressTarget) {
          this.addressTarget.value = results[0].formatted_address
        }
      }
    })
  }

  searchAddress(event) {
    event.preventDefault()
    
    if (!this.hasAddressTarget || !this.addressTarget.value.trim()) {
      alert("Please enter an address to search")
      return
    }

    const address = this.addressTarget.value.trim()
    const geocoder = new google.maps.Geocoder()

    geocoder.geocode({ address: address }, (results, status) => {
      if (status === 'OK' && results[0]) {
        const location = results[0].geometry.location
        // Allow centering anywhere; acceptance is validated on submit
        this.map.setCenter(location)
        this.map.setZoom(16)
        this.marker.setPosition(location)
        this.updateCoordinates(location)
      } else {
        alert("Address not found. Please try a different address or click on the map.")
      }
    })
  }

  // Validate on submit: must be Parañaque or approved shared zones
  validateSubmit(event) {
    const address = this.hasAddressTarget ? (this.addressTarget.value || '').toLowerCase() : ''
    const lat = this.hasLatitudeTarget ? parseFloat(this.latitudeTarget.value) : null
    const lng = this.hasLongitudeTarget ? parseFloat(this.longitudeTarget.value) : null

    const containsParanaque = address.includes('parañaque') || address.includes('paranaque')
    const inWhitelist = (lat && lng) ? this.isWithinWhitelist(lat, lng) : false

    if (!containsParanaque && !inWhitelist) {
      event.preventDefault()
      this.notify('Address must be in Parañaque. Please enter a Parañaque address in the search box (shared zones NAIA/Okada/Parqal/Ayala Malls are allowed).')
    }
  }

  // Hook up submit listener
  initialize() {
    this.attachSubmitListener = () => {
      const form = this.element.closest('form')
      if (form && !this._submitAttached) {
        form.addEventListener('submit', this.validateSubmit.bind(this))
        this._submitAttached = true
      }
    }
  }

  // Ensure listener after map init
  connected() {
    this.attachSubmitListener()
  }
}

