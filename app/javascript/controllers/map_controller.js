import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map"
export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number,
    markers: Array, // For multiple markers (barangay page)
    zoom: { type: Number, default: 15 }
  }

  connect() {
    // Wait for Google Maps API to load
    if (typeof google === 'undefined') {
      this.waitForGoogleMaps()
    } else {
      this.initializeMap()
    }
  }

  waitForGoogleMaps() {
    const checkGoogleMaps = setInterval(() => {
      if (typeof google !== 'undefined' && google.maps) {
        clearInterval(checkGoogleMaps)
        this.initializeMap()
      }
    }, 100)
    
    // Timeout after 10 seconds
    setTimeout(() => {
      clearInterval(checkGoogleMaps)
      if (typeof google === 'undefined') {
        console.error('Google Maps failed to load')
        this.element.innerHTML = '<div class="text-center text-red-600 p-4">Map failed to load. Please refresh the page.</div>'
      }
    }, 10000)
  }

  initializeMap() {
    // Default center (Paranaque City Hall)
    const center = {
      lat: this.hasLatitudeValue ? this.latitudeValue : 14.4793,
      lng: this.hasLongitudeValue ? this.longitudeValue : 121.0198
    }

    // Create map
    this.map = new google.maps.Map(this.element, {
      center: center,
      zoom: this.zoomValue,
      mapTypeControl: true,
      streetViewControl: true,
      fullscreenControl: true,
      zoomControl: true,
      styles: [
        {
          featureType: "poi",
          elementType: "labels",
          stylers: [{ visibility: "off" }]
        }
      ]
    })

    // Add markers
    if (this.hasMarkersValue && this.markersValue.length > 0) {
      this.addMultipleMarkers()
    } else if (this.hasLatitudeValue && this.hasLongitudeValue) {
      this.addSingleMarker()
    }
  }

  addSingleMarker() {
    const position = {
      lat: this.latitudeValue,
      lng: this.longitudeValue
    }

    const marker = new google.maps.Marker({
      position: position,
      map: this.map,
      title: "Location",
      animation: google.maps.Animation.DROP
    })

    // Center map on marker
    this.map.setCenter(position)
  }

  addMultipleMarkers() {
    const bounds = new google.maps.LatLngBounds()
    const infoWindow = new google.maps.InfoWindow()

    this.markersValue.forEach(markerData => {
      const position = {
        lat: markerData.latitude,
        lng: markerData.longitude
      }

      // Determine marker color based on status and priority
      const icon = this.getMarkerIcon(markerData.status, markerData.priority)

      const marker = new google.maps.Marker({
        position: position,
        map: this.map,
        title: markerData.title,
        icon: icon,
        animation: google.maps.Animation.DROP
      })

      // Add click listener for info window
      marker.addListener('click', () => {
        const content = this.createInfoWindowContent(markerData)
        infoWindow.setContent(content)
        infoWindow.open(this.map, marker)
      })

      // Extend bounds to include this marker
      bounds.extend(position)
    })

    // Fit map to show all markers
    if (this.markersValue.length > 1) {
      this.map.fitBounds(bounds)
    } else if (this.markersValue.length === 1) {
      this.map.setCenter(bounds.getCenter())
      this.map.setZoom(15)
    }
  }

  getMarkerIcon(status, priority) {
    let color

    // Critical priority takes precedence
    if (priority === 'critical') {
      color = 'red'
    } else {
      // Color by status
      switch (status) {
        case 'pending':
          color = 'yellow'
          break
        case 'in_progress':
          color = 'orange'
          break
        case 'resolved':
          color = 'green'
          break
        case 'closed':
          color = 'gray'
          break
        default:
          color = 'blue'
      }
    }

    // Use Google's default colored markers
    return `http://maps.google.com/mapfiles/ms/icons/${color}-dot.png`
  }

  createInfoWindowContent(markerData) {
    const statusColors = {
      pending: 'bg-yellow-100 text-yellow-800',
      in_progress: 'bg-orange-100 text-orange-800',
      resolved: 'bg-green-100 text-green-800',
      closed: 'bg-gray-100 text-gray-800'
    }

    const priorityColors = {
      low: 'bg-gray-100 text-gray-800',
      medium: 'bg-yellow-100 text-yellow-800',
      high: 'bg-orange-100 text-orange-800',
      critical: 'bg-red-100 text-red-800'
    }

    return `
      <div style="max-width: 300px; padding: 8px;">
        <h3 style="font-size: 16px; font-weight: bold; margin-bottom: 8px; color: #1f2937;">
          ${markerData.title}
        </h3>
        <div style="margin-bottom: 8px;">
          <span style="display: inline-block; padding: 4px 8px; border-radius: 9999px; font-size: 12px; font-weight: 600; ${this.getInlineStyles(statusColors[markerData.status])}">
            ${this.titleize(markerData.status)}
          </span>
          <span style="display: inline-block; padding: 4px 8px; border-radius: 9999px; font-size: 12px; font-weight: 600; margin-left: 4px; ${this.getInlineStyles(priorityColors[markerData.priority])}">
            ${this.titleize(markerData.priority)} Priority
          </span>
        </div>
        <p style="color: #4b5563; font-size: 14px; margin-bottom: 8px;">
          ${markerData.description ? this.truncate(markerData.description, 100) : ''}
        </p>
        <p style="color: #6b7280; font-size: 12px; margin-bottom: 8px;">
          📍 ${markerData.address}
        </p>
        <a href="${markerData.url}" 
           style="display: inline-block; background-color: #2563eb; color: white; padding: 6px 12px; border-radius: 6px; text-decoration: none; font-size: 14px; font-weight: 600;">
          View Report →
        </a>
      </div>
    `
  }

  getInlineStyles(tailwindClasses) {
    const colorMap = {
      'bg-yellow-100 text-yellow-800': 'background-color: #fef3c7; color: #92400e;',
      'bg-orange-100 text-orange-800': 'background-color: #ffedd5; color: #9a3412;',
      'bg-green-100 text-green-800': 'background-color: #dcfce7; color: #166534;',
      'bg-gray-100 text-gray-800': 'background-color: #f3f4f6; color: #1f2937;',
      'bg-red-100 text-red-800': 'background-color: #fee2e2; color: #991b1b;'
    }
    return colorMap[tailwindClasses] || ''
  }

  titleize(str) {
    return str.replace(/_/g, ' ').replace(/\b\w/g, char => char.toUpperCase())
  }

  truncate(str, length) {
    return str.length > length ? str.substring(0, length) + '...' : str
  }
}

