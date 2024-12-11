<script setup>
  import { ref, reactive } from 'vue'
  
  import PayeeSearch from './PayeeSearch.vue'
  import MoneyField from './MoneyField.vue'

  const props = defineProps(['rendered_service', 'payee', 'hourly_rate', 'artists', 'albums'])

  const service = reactive(props.rendered_service)
  const payee = ref(props.payee || { name: '', fsn: '' })

  const compensation = ref({ cents: service.compensation_cents, currency: service.compensation_currency })

  function clearHoursIfFixed() {
    if (service.type === 'fixed') {
      service.hours = null
    }
  }

  function recomputeCompensation() {
    if (service.type === 'hourly') {
      compensation.value.cents = (service.hours * props.hourly_rate) * 100
    }
  }
</script>


<!-- NOTE: assumes already in a form -->
<template>
  <div class="field">
    <label class="label is-required">Payee</label>
    <div class="control">
      <PayeeSearch v-model="payee" fieldName="rendered_service[payee][fsn]"/>
    </div>
  </div>

  <div class="field">
    <label class="label is-required">Date Rendered</label>
    <div class="control">
      <input class="input" name="rendered_service[rendered_at]" type="date" v-model="service.rendered_at">
    </div>
  </div>

  <div class="field">
    <label class="label">Description</label>
    <div class="control">
      <textarea class="textarea" name="rendered_service[description]" v-model="service.description"></textarea>
    </div>
  </div>

  <div class="field">
    <label class="label">For Project</label>
    <div class="control">
      <div class="select">
        <select name="rendered_service[album_id]" v-model="service.album_id">
          <option></option>
          <option :value="id" v-for="[id, name] in props.albums">{{ name }}</option>
        </select>
      </div>
      <p class="help">
        If an album is assigned, these costs will be paid out from album revenue before any royalty payments.
      </p>
    </div>
  </div>

  <div class="field">
    <label class="label">For Artist</label>
    <div class="control">
      <div class="select">
        <select name="rendered_service[type]" v-model="service.artist_name">
          <option></option>
          <option v-for="artist in props.artists">{{ artist }}</option>
        </select>
      </div>
    </div>
  </div>

  <div class="field">
    <label class="label is-required">Type</label>
    <div class="control">
      <div class="select">
        <select name="rendered_service[type]" v-model="service.type" @change="clearHoursIfFixed">
          <option value="fixed">Fixed amount</option>
          <option value="hourly">Hourly</option>
        </select>
      </div>
    </div>
  </div>

  <div class="field" v-if="service.type == 'hourly'">
    <label class="label is-required">Hours</label>
    <div class="control">
      <input name="rendered_service[hours]" class="input" type="number" step=".05" autocomplete="off" v-model="service.hours" @input="recomputeCompensation" />
    </div>
  </div>

  <div class="field">
    <label class="label is-required">Compensation</label>
    <div class="control">
      <MoneyField v-model="compensation" name="rendered_service[compensation]" />
    </div>
  </div>
</template>
