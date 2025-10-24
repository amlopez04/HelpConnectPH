import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="location-picker"
export default class extends Controller {
  static targets = ["map", "latitude", "longitude", "address", "searchButton"]
  static values = {
    apiKey: String,
    defaultLat: { type: Number, default: 14.4793 }, // Parañaque City Center
    defaultLng: { type: Number, default: 121.0198 }
  }

  connect() {
    this.initializeMap()
  }

  initializeMap() {
    // Default location (Parañaque City Center)
    const center = {
      lat: this.defaultLatValue,
      lng: this.defaultLngValue
    }

    // Create the map
    this.map = new google.maps.Map(this.mapTarget, {
      center: center,
      zoom: 13,
      mapTypeControl: true,
      streetViewControl: true,
      fullscreenControl: true
    })

    // Create a marker
    this.marker = new google.maps.Marker({
      position: center,
      map: this.map,
      draggable: true,
      title: "Drag me to your location!"
    })

    // Add click listener to map
    this.map.addListener('click', (event) => {
      this.placeMarker(event.latLng)
    })

    // Add drag listener to marker
    this.marker.addListener('dragend', (event) => {
      this.updateCoordinates(event.latLng)
    })

    // Try to get user's current location
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const userLocation = {
            lat: position.coords.latitude,
            lng: position.coords.longitude
          }
          this.map.setCenter(userLocation)
          this.marker.setPosition(userLocation)
          this.updateCoordinates(userLocation)
        },
        (error) => {
          console.log("Geolocation error:", error)
          // Stay at default location if geolocation fails
        }
      )
    }
  }

  placeMarker(location) {
    this.marker.setPosition(location)
    this.updateCoordinates(location)
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
          // Update address field with formatted address
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
        this.map.setCenter(location)
        this.map.setZoom(16)
        this.marker.setPosition(location)
        this.updateCoordinates(location)
      } else {
        alert("Address not found. Please try a different address or click on the map.")
      }
    })
  }
}

