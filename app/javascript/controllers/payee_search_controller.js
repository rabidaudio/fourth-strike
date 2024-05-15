import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['searchField', 'hiddenField', 'results']

  connect () {
    this.dirty = false
    this.lastValue = this.searchFieldTarget.value
  }

  onInput () {
    if (this.searchFieldTarget.value === "") {
      // if emptied, clear the value
      this.searchFieldTarget.value = ""
      this.hiddenFieldTarget.value = ""
      this.dirty = false
      this.lastValue = ""
    } else {
      // otherwise load results using Turbo
      this.dirty = true
      // TODO: debounce
      this.element.requestSubmit()
    }
  }

  onSelect (event) {
    event.preventDefault()

    this.searchFieldTarget.value = event.target.textContent
    this.hiddenFieldTarget.value = event.target.getAttribute('fsn')
    this.lastValue = event.target.textContent
    this.dirty = false
    this.clearResults()
  }

  onBlur (event) {
    if (event.relatedTarget && event.relatedTarget.getAttribute('fsn') !== null) {
      return // there is select event incoming, so wait for that
    }

    this.clearResults()
    if (this.dirty) {
      // reset it
      this.searchFieldTarget.value = this.lastValue
      this.dirty = false
    }
  }

  clearResults () {
    this.resultsTarget.innerHTML = ''
  }
}
