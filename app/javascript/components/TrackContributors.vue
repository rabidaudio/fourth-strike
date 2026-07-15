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
      artist: { name: '', id: null },
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
  .edit-splits td {
    /* Make the text cells have the same height as the inputs */
    line-height: var(--bulma-control-height);
  }
  .edit-splits td button.delete {
    vertical-align: text-top;
  }
</style>

<template>
  <div class="edit-contributions">
      <table class="table is-fullwidth">
        <thead>
          <tr>
            <th>Contributor</th>
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
        <tbody v-for="(contribution, index) in contributions" v-bind:key="contribution.artist_id">
          <tr>
            <td>
              <PayeeSearch v-model="contribution.artist.payee" artistOnly="true" fieldName="contributions[][fsn]"/>
            </td>
            <td>
              <div class="field">
                <div class="control">
                  <label class="checkbox">
                    <input type="checkbox" name="contributions[][is_songwriter]" v-model="contribution.is_songwriter" />
                    <span> Songwriter?</span>
                  </label>
                </div>
              </div>
            </td>
            <td>
              <button class="delete" @click.prevent="removeContributorAt(index)"></button>
            </td>
          </tr>
          <tr>
            <td colspan="3">
              <div class="field">
                <div class="control">
                  <input class="input" type="text" name="contributions[][details]"
                    v-model="contribution.details"
                    placeholder="details (vocals, guitar)"
                    autocomplete="off"/>
                </div>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
  </div>
</template>
