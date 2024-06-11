<script setup>
  import { computed, triggerRef, defineModel } from 'vue'

  const money = defineModel({ default: { cents: 0, currency: 'USD' } })

  const props = defineProps(['name'])

  function format(money) {
    return '$' + (Math.round(money.cents) / 100).toFixed(2)
  }

  const displayValue = computed({
    get() {
      return format(money.value)
    }
  })

  function appendSuffix(suffix) {
    return props.name.replace(/]$/, `_${suffix}]`)
  }

  function setValue(value) {
    if (value.startsWith('$')) value = value.substring(1)
    money.value.cents = Math.round(100 * parseFloat(value))
    triggerRef(money)
  }
</script>

<template>
  <input type="hidden" :name="appendSuffix('cents')" :value="money.cents">
  <input type="hidden" :name="appendSuffix('currency')" :value="money.currency">
  <input :name="props.name" class="input" :value="displayValue" @blur="setValue($event.target.value)" />
</template>
