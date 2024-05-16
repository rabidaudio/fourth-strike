import { createApp } from 'vue'

import PayeeSearch from './PayeeSearch.vue'
import EditSplits from './EditSplits.vue'

const Components = {
  PayeeSearch,
  EditSplits
}

window.addEventListener('turbo:load', () => {
  for (const el of document.querySelectorAll('[vue-component]')) {
    const componentName = el.getAttribute('vue-component')
    const component = Components[componentName]
    const props = JSON.parse(el.getAttribute('props') || '{}')
    if (!component) {
      console.warn('Unable to find component', componentName)
    } else {
      createApp(component, props).mount(el)
    }
  }
})

export default Components
