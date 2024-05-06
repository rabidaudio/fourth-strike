import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['toggleable', 'checkbox']

  connect () {
    for (const checkbox of this.checkboxTargets) {
      if (checkbox.checked) {
        this.show()
      } else {
        this.hide()
      }
    }
  }

  toggle () {
    for (const target of this.toggleableTargets) {
      target.classList.toggle('is-active')
    }
  }

  show () {
    for (const target of this.toggleableTargets) {
      target.classList.add('is-active')
    }
  }

  hide () {
    for (const target of this.toggleableTargets) {
      target.classList.remove('is-active')
    }
  }

  checkbox (event) {
    if (event.target.checked) {
      this.show()
    } else {
      this.hide()
    }
  }
}
