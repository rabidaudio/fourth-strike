import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect () {
    this.element.classList.add('spoiler-hidden')
    this.element.addEventListener('click', (e) => {
      e.preventDefault()
      e.target.classList.remove('spoiler-hidden')
    })
  }
}
