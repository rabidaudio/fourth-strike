// Entry point for the build script in your package.json
import '@hotwired/turbo-rails'

import './bulma-tags'
import './controllers'
import './components'

import * as Routes from './routes'
window.Routes = Routes
