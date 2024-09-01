<script setup>
  import { computed } from 'vue'
  import { Bar } from 'vue-chartjs'
  import 'chart.js/auto'

  const props = defineProps(['data'])

  const chartOptions = computed(() =>({
    responsive: true,
    maintainAspectRatio: true,
    scales: {
      x: {
        display: false
      },
      revenue: {
        type: 'linear',
        position: 'left',
        title: {
          display: true,
          text: 'Revenue'
        }
      },
      // streams: {
      //   type: 'linear',
      //   position: 'right',
      //   suggestedMin: computeSuggestedMin(),
      //   title: {
      //     display: true,
      //     text: 'Streams'
      //   }
      // }
    }
  }))

  const chartData = {
    labels: props.data.map((a) => a.name),
    datasets: [
      {
        type: 'bar',
        label: 'Organization Profit',
        yAxisID: 'revenue',
        data: props.data.map((a) => a.organization_profit)
      },
      // {
      //   type: 'line',
      //   label: 'Streams',
      //   yAxisID: 'streams',
      //   data: props.data.map((a) => a.streams)
      // },
    ]
  }
</script>

<template>
  <div style="max-height: 350px;">
    <Bar
      :options="chartOptions"
      :data="chartData"
    />
  </div>
</template>
