import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'filename']

  connect () {
    this.placeholderText = this.filenameTarget.textContent
    this.inputTarget.addEventListener('change', () => this.update())
    this.update()
  }

  update () {
    if (this.inputTarget.files[0]) {
      this.showFileName()
    } else {
      this.showPlaceholder()
    }
  }

  showPlaceholder () {
    this.filenameTarget.textContent = this.placeholderText
    this.filenameTarget.classList.add('is-italic')
    this.filenameTarget.classList.add('has-text-grey')
  }

  showFileName () {
    this.filenameTarget.textContent = this.inputTarget.files[0].name
    this.filenameTarget.classList.remove('is-italic')
    this.filenameTarget.classList.remove('has-text-grey')
  }
}
