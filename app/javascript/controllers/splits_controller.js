import { Controller } from '@hotwired/stimulus'

/**
 * A controller for editing product contributor splits. It adds/removes input fields
 * and validates values. See splits/edit.html.slim
 */
export default class extends Controller {
  static targets = ['split']

  connect () {
    this.recomputeSplits()
  }

  removeContributor (event) {
    event.preventDefault()

    event.target.closest('tr.split').remove()
  }

  recomputeSplits () {
    const total = this.totalSplitValue
    for (const split of this.splitTargets) {
      const value = this.getValue(split)
      const isValid = value !== null && value > 0
      this.setIsValid(split, isValid)

      if (total === 0 || total === null || !isValid) {
        this.setComputed(split, null)
      } else {
        this.setComputed(split, value / total)
      }
    }
  }

  setComputed (split, value) {
    if (value === null) {
      split.querySelector('.computed').textContent = ''
    } else {
      split.querySelector('.computed').textContent = `${Math.round(value * 100 * 100) / 100}%`
    }
  }

  setIsValid (split, isValid) {
    if (isValid) {
      split.querySelector('.split-value').classList.remove('is-danger')
    } else {
      split.querySelector('.split-value').classList.add('is-danger')
    }
  }

  getValue (split) {
    const textValue = split.querySelector('.split-value').value
    if (!textValue.match(/^-?[0-9]+$/)) return null
    return parseInt(textValue, 10)
  }

  get totalSplitValue () {
    let sum = 0
    for (const split of this.splitTargets) {
      const v = this.getValue(split)
      if (v === null) return null
      sum += v
    }
    return sum
  }
}
