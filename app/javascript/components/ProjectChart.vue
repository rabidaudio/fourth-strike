<script setup>
  import { ref, computed } from 'vue'
  import { Bar } from 'vue-chartjs'
  import 'chart.js/auto'

  const props = defineProps(['data'])

  const ticks = ref(10)

  function accumulate(data) {
    let total = 0
    return data.map(v => {
      total += v
      return total
    })
  }

  function ratio(numerator, denominator) {
    return numerator.map((n, i) => n / denominator[i])
  }

  const chartOptions = computed(() =>({
    responsive: true,
    maintainAspectRatio: true,
    scales: {
      x: {
        display: false
      },
      income_project: {
        type: 'linear',
        position: 'left',
        title: {
          display: true,
          text: 'Income (Project)'
        },
        afterBuildTicks: (axis) => ticks.value = axis.ticks.length
      },
      // income_cumulative: {
      //   type: 'linear',
      //   position: 'right',
      //   title: {
      //     display: true,
      //     text: 'Income (Cumulative)'
      //   }
      // },
      percent: {
        type: 'linear',
        position: 'right',
        title: {
          display: true,
          text: 'Org Distribution'
        },
        ticks: {
          count: ticks.value,
          callback: (value) => Math.round(value*100)/100 + '%'
        }
      }
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
        label: 'Income',
        yAxisID: 'income_project',
        data: props.data.map((a) => a.distributable_income)
      },
      {
        type: 'bar',
        label: 'Organization Profit',
        yAxisID: 'income_project',
        data: props.data.map((a) => a.organization_profit)
      },

      // {
      //   type: 'line',
      //   label: 'Total Income',
      //   yAxisID: 'income_cumulative',
      //   data: accumulate(props.data.map((a) => a.distributable_income))
      // },
      // {
      //   type: 'line',
      //   label: 'Organization Profit',
      //   yAxisID: 'income_cumulative',
      //   data: accumulate(props.data.map((a) => a.organization_profit))
      // },
      {
        type: 'line',
        label: 'Cumulative Effective Org Distribution',
        yAxisID: 'percent',
        data: ratio(accumulate(props.data.map((a) => 100*a.organization_profit)), accumulate(props.data.map((a) => a.distributable_income)))
      },


      // {
      //   type: 'line',
      //   label: 'Ratio',
      //   yAxisID: 'percent',
      //   data: props.data.map((a) => a.organization_profit / a.distributable_income * 100.0)
      // }
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
