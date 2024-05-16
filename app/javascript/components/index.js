import { createApp } from 'vue'

import PayeeSearch from './PayeeSearch.vue'

const Components = {
  PayeeSearch
}

window.addEventListener('turbo:load', () => {
  for (const el of document.querySelectorAll('[vue-component]')) {
    const componentName = el.getAttribute('vue-component')
    const component = Components[componentName]
    if (!component) {
      console.warn('Unable to find component', componentName)
    } else {
      createApp(component).mount(el)
    }
  }
})

export default Components
