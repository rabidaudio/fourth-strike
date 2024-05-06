// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'
import './controllers'

import BulmaTagsInput from '@creativebulma/bulma-tagsinput'

window.addEventListener('DOMContentLoaded', () => BulmaTagsInput.attach())
