<script setup>
  import { ref, computed } from 'vue'

  import PayeeSearch from './PayeeSearch.vue'

  const props = defineProps(['contributions', 'track_id'])
  
  const track_id = props.track_id
  const contributions = ref(props.contributions || [])

  const hasSongwriters = computed(() => {
    for (const index in contributions.value) {
      const contribution = contributions.value[index]
      if (contribution.level === 'songwriter') return true
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
      level: hasSongwriters.value ? 'contributor' : 'songwriter',
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
  <div class="edit-contributions">
      <div class="contribution card" v-for="(contribution, index) in contributions" v-bind:key="contribution.artist_id">
        <div class="field is-grouped is-grouped-multiline">
          <input type="hidden" name="contributions[][track_id]" :value="track_id">
          <PayeeSearch v-model="contribution.payee" artistOnly fieldName="contributions[][fsn]"/>

          <div class="control has-icons-left">
            <div class="select">
              <select name="contributions[][level]" v-model="contribution.level">
                <option value="songwriter">Songwriter</option>
                <option value="contributor">Contributor</option>
                <option value="associated">Associated</option>
              </select>
              <div class="icon is-small is-left">
                <span :class="{'songwriter': 'has-text-success', 'contributor': 'has-text-dark', 'associated': ''}[contribution.level]">
                  <i :class="{'songwriter': 'ri-quill-pen-ai-line', 'contributor': 'ri-add-line', 'associated': 'ri-info-i'}[contribution.level]"></i>
                </span>
              </div>
            </div>
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
