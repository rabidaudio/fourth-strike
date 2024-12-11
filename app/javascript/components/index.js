import { createApp } from 'vue'

import PayeeSearch from './PayeeSearch.vue'
import EditSplits from './EditSplits.vue'
import RenderedServiceForm from './RenderedServiceForm.vue'
import MoneyField from './MoneyField.vue'
import StreamingChart from './StreamingChart.vue'
import SaleChart from './SaleChart.vue'
import ProjectChart from './ProjectChart.vue'
import AlbumForm from './AlbumForm.vue'

const Components = {
  PayeeSearch,
  EditSplits,
  RenderedServiceForm,
  MoneyField,
  StreamingChart,
  SaleChart,
  ProjectChart,
  AlbumForm
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
