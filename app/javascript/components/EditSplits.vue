<script setup>
  import { ref, computed } from 'vue'

  import PayeeSearch from './PayeeSearch.vue'

  const props = defineProps(['splits'])

  const splits = ref(props.splits || [])

  if (splits.length === 0) {
    addContributor()
  }

  const isValid = computed(() => 
    splits.value.map((v) => typeof v.value !== "string" && v.value >= 1 && Math.round(v.value) === v.value)
  )

  const allValid = computed(() => {
    for (const v of isValid.value) {
      if (!v) return false
    }
    return true
  })

  const computedSplits = computed(() => {
    if (splits.value.length === 0) return []

    let sum = 0
    for (const index in splits.value) {
      const split = splits.value[index]
      if (split.payee.fsn !== "" && isValid.value[index]) {
        sum += split.value
      }
    }
    return splits.value.map((v, i) => v.payee.fsn === "" || !isValid.value[i] ? "" : toPercentage(v.value / sum, 2))
  })

  function addContributor() {
    splits.value.push({ payee: { name: '', fsn: '' }, value: 1 })
  }

  function removeContributorAt(index) {
    splits.value.splice(index, 1)
  }

  function toPercentage(fraction, precision) {
    const value = Math.round(fraction * Math.pow(10, precision + 2)) / Math.pow(10, precision)
    return `${value}%`
  }
</script>

<style>
  .edit-splits td {
    /* Make the text cells have the same height as the inputs */
    line-height: var(--bulma-control-height);
  }
  .edit-splits td button.delete {
    vertical-align: text-top;
  }
</style>

<template>
  <table class="edit-splits table is-fullwidth">
    <thead>
      <tr>
        <th>Contributor</th>
        <th>Share</th>
        <th></th>
        <th></th>
      </tr>
    </thead>
    <tfoot>
      <tr>
        <th colspan="4">
          <button class="button" @click.prevent="addContributor">Add Contributor</button>
        </th>
      </tr>
    </tfoot>
    <tbody v-for="(split, index) in splits" v-bind:key="split.payee.fsn">
      <tr>
        <td>
          <PayeeSearch v-model="split.payee" fieldName="splits[][fsn]"/>
        </td>
        <td>
          <div class="field">
            <div class="control">
              <input class="input" type="number" name="splits[][value]"
                v-model="split.value"
                autocomplete="off"
                :class="{ 'is-danger': !isValid[index] }"/>
            </div>
          </div>
        </td>
        <td>{{ computedSplits[index] }}</td>
        <td>
          <button class="delete" @click.prevent="removeContributorAt(index)"></button>
        </td>
      </tr>
    </tbody>
  </table>
</template>
