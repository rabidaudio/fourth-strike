import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['toggleable']

  toggle () {
    for (const target of this.toggleableTargets) {
      target.classList.toggle('is-active')
    }
  }
}
