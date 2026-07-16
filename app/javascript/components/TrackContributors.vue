<script setup>
  import { ref, computed } from 'vue'

  import PayeeSearch from './PayeeSearch.vue'

  const props = defineProps(['contributions', 'track_id'])
  
  const track_id = props.track_id
  const contributions = ref(props.contributions || [])

  const hasSongwriters = computed(() => {
    for (const index in contributions.value) {
      const contribution = contributions.value[index]
      if (contribution.is_songwriter) return true
    }
    return false
  })

  function addContributor() {
    contributions.value.push({
      payee: {
        fsn: '',
        name: '',
      },
      track_id,
      is_songwriter: !hasSongwriters.value,
      details: ''
    })
  }

  function removeContributorAt(index) {
    contributions.value.splice(index, 1)
  }
</script>

<style>
  .edit-contributions {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }
  
  .contribution {
    padding: 10px;
  }

  .contribution .field {
    /* Make the text cells have the same height as the inputs */
    line-height: var(--bulma-control-height);
  }
  .contribution .field button.delete {
    vertical-align: text-top;
  }
</style>

<template>
  <input type="hidden" name="contributions[][track_id]" :value="track_id">
  <div class="edit-contributions">
      <div class="contribution card" v-for="(contribution, index) in contributions" v-bind:key="contribution.artist_id">
        <div class="field is-grouped is-grouped-multiline">
          <PayeeSearch v-model="contribution.payee" artistOnly fieldName="contributions[][fsn]"/>

          <div class="control">
            <label class="checkbox">
              <input type="checkbox" name="contributions[][is_songwriter]" v-model="contribution.is_songwriter" />
              <span> Songwriter</span>
            </label>
          </div>

          <div class="control">
            <button class="delete" @click.prevent="removeContributorAt(index)"></button>
          </div>
        </div>

        <div class="field">
          <div class="control">
            <input class="input" type="text" name="contributions[][details]"
              v-model="contribution.details"
              placeholder="details (vocals, guitar)"
              autocomplete="off"/>
          </div>
        </div>
      </div>

      <button class="button" @click.prevent="addContributor">Add Contributor</button>
  </div>
</template>
