<script setup>
  import { ref, computed } from 'vue'
  import { Line } from 'vue-chartjs'
  import 'chart.js/auto'

  // data: Object of labels to numbers
  const props = defineProps(['data'])

  const isLog = ref(false)

  const chartOptions = computed(() => ({
    responsive: true,
    scales: {
      x: {
        title: {
          display: true,
          text: 'Month'
        }
      },
      y: {
        stacked: true,
        type: isLog.value ? 'logarithmic' : 'linear',
        title: {
          display: true,
          text: 'Streams'
        }
      }
    }
  }))

  const chartData = {
    labels: Object.keys(props.data),
    datasets: [ { label: 'Streams', data: Object.values(props.data) } ]
  }
</script>

<template>
  <Line
    :options="chartOptions"
    :data="chartData"
  />
  <div class="tags has-addons">
    <span class="tag" :class="{ 'is-primary': !isLog }" @click="isLog = false">Linear</span>
    <span class="tag" :class="{ 'is-primary': isLog }" @click="isLog = true">Logarithmic</span>
  </div>
</template>
