<script setup>
  import { ref, computed, defineModel } from 'vue'

  import { payees_path } from '../routes'

  const props = defineProps({
    fieldName: String
  })

  const payee = defineModel({ default: { name: '', fsn: '' } })
  const selectedFsn = computed(() => payee.value.fsn)
  const searchValue = ref(payee.value.fsn === '' ? '' : `${payee.value.name} / ${payee.value.fsn}`)
  const searchResults = ref([])
  const isFocused = ref(false)
  const isDirty = ref(false)
  const isFilled = computed(() => !isDirty.value && selectedFsn.value !== "")
  const isInvalid = computed(() => !isFocused.value && isDirty.value)

  async function search(event) {
    payee.value = { name: '', fsn: '' }
    searchValue.value = event.target.value
    
    if (event.target.value === "") {
      isDirty.value = false
      return
    }
    isDirty.value = true

    await loadResults(event.target.value)
  }

  async function loadResults(search) {
    // TODO: debounce? queue?
    const res = await fetch(payees_path({ search, limit: 10, format: 'json' }))
    const data = await res.json()
    searchResults.value = data
  }

  async function resume() {
    isFocused.value = true
    if (isDirty.value) {
      await loadResults(searchValue.value)
    }
  }

  function clear(event) {
    isFocused.value = false
    if (!isDirty.value) {
      return // nothing to change
    }
    if (event.relatedTarget && event.relatedTarget.classList.contains('panel-block')) {
      return // there is select event incoming, so wait for that
    }
    searchResults.value = []
  }

  function select(selectedPayee) {
    payee.value = selectedPayee
    searchValue.value = `${selectedPayee.name} / ${selectedPayee.fsn}`
    searchResults.value = []
    isDirty.value = false
  }
</script>

<style>
.payee-search .filled {
  text-decoration: underline;
}
</style>

<template>
  <nav class="panel payee-search">
    <div>
      <p class="control" :class="{'has-icons-left': !isFilled, 'has-icons-right': isFilled}">
        <input type="text" class="input" placeholder="Search" autocomplete="off"
          @input="search"
          @focus="resume"
          @blur="clear"
          :class="{ 'filled': isFilled, 'is-danger': isInvalid }"
          :value="searchValue" />
        <span v-if="!isFilled" class="icon is-left">
          <i class="ri-search-line" aria-hidden="true"></i>
        </span>
        <span v-if="isFilled" class="icon is-small is-right has-text-success">
          <i class="ri-check-line"></i>
        </span>
        
        <div v-for="payee in searchResults" v-bind:key="payee.fsn">
          <a href="#" class="panel-block is-active" @click.prevent="select(payee)">{{ payee.name }} / {{ payee.fsn }}</a>
        </div>
      </p>
      <input type="hidden" :name="fieldName" :value="selectedFsn"/>
    </div>
  </nav>
</template>
