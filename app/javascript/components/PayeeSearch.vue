<script setup>
  import { ref, computed } from 'vue'

  import { payees_path } from '../routes'

  const searchValue = ref("")
  const selectedFsn = ref("")
  const searchResults = ref([])
  const isFocused = ref(false)
  const isDirty = ref(false)
  const isFilled = computed(() => !isDirty.value && selectedFsn.value !== "")
  const isInvalid = computed(() => !isFocused.value && isDirty.value)

  async function search(event) {
    if (event.target.value === "") {
      clearSelection()
      return
    }

    isDirty.value = true
    selectedFsn.value = ""
    searchValue.value = event.target.value

    // TODO: debounce? queue?
    const res = await fetch(payees_path({ search: event.target.value, limit: 10, format: 'json' }))
    const data = await res.json()
    searchResults.value = data
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

  function select(payee, event) {
    event.preventDefault()
    selectedFsn.value = payee.fsn
    searchResults.value = []
    isDirty.value = false
    searchValue.value = `${payee.name} / ${payee.fsn}`
  }

  function clearSelection() {
    searchValue.value = ""
    selectedFsn.value = ""
    isDirty.value = false
  }
</script>

<style>
.filled {
  text-decoration: underline;
}
</style>

<template>
  <nav class="panel">
    <div>
      <p class="control has-icons-left has-icons-right">
        <input type="text" class="input" placeholder="Search" autocomplete="off"
          @input="search"
          @focus="isFocused = true"
          @blur="clear"
          :class="{ 'filled': isFilled, 'is-danger': isInvalid }"
          :value="searchValue" />
        <span class="icon is-left">
          <i class="ri-search-line" aria-hidden="true"></i>
        </span>
        <span v-if="isFilled" class="icon is-small is-right has-text-success">
          <i class="ri-check-line"></i>
        </span>
        
        <div v-for="payee in searchResults" v-bind:key="payee.fsn">
          <a href="#" class="panel-block is-active" @click="select(payee, $event)">{{ payee.name }} / {{ payee.fsn }}</a>
        </div>
      </p>
      <input type="hidden" name="fsn" :value="selectedFsn"/>
    </div>
  </nav>
</template>
