import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["drawer"]

  declare readonly drawerTarget: HTMLElement

  open() {
    this.drawerTarget.classList.remove("hidden")
  }

  close() {
    this.drawerTarget.classList.add("hidden")
  }
}
