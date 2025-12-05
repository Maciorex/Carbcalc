import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["totalCarbs", "volume"]

  static values = { mode: String }

  connect() {
    if (!this.hasModeValue) {
      this.modeValue = "carbs_target"
    }
    this.updateInputs()
  }

  changeMode(event) {
    this.modeValue = event.target.value
    this.updateInputs()
  }

  updateInputs() {
    if (!this.hasTotalCarbsTarget || !this.hasVolumeTarget) return

    if (this.modeValue === "carbs_target") {
      this.totalCarbsTarget.disabled = false
      this.volumeTarget.disabled = true
    } else if (this.modeValue === "volume_target") {
      this.totalCarbsTarget.disabled = true
      this.volumeTarget.disabled = false
    }
  }
}

