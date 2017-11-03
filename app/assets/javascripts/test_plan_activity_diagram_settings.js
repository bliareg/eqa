function init_test_activities_diagrams() {
  if($('#testingActivities').length) {
    ctx = document.getElementById("test_cases_counting_chart");
    lineChartData = {
      labels: gon.test_order.labels,
      datasets: [
        {
          label: gon.test_order.items[0][0],
          fill: false,
          backgroundColor: "rgba(255, 99, 132, 0.8)",
          borderColor: "rgba(255, 99, 132, 0.8)",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(255, 99, 132,1)",
          pointBackgroundColor: "#fff",
          pointBorderWidth: 1,
          pointHoverRadius: 5,
          pointHoverBackgroundColor: "rgba(255, 99, 132,1)",
          pointHoverBorderWidth: 1,
          pointRadius: 4,
          pointHitRadius: 10,
          lineTension: 0,
          spanGaps: false,
          borderColor: 'rgba(255, 99, 132, 1)',
          data: gon.test_order.items[0][1]
        },
        {
          label: gon.test_order.items[1][0],
          fill: false,
          backgroundColor: "rgba(54, 162, 235, 0.8)",
          borderColor: "rgba(54, 162, 235, 0.8)",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(54, 162, 235,1)",
          pointBackgroundColor: "#fff",
          pointBorderWidth: 1,
          pointHoverRadius: 5,
          pointHoverBackgroundColor: "rgba(54, 162, 235,1)",
          pointHoverBorderWidth: 1,
          pointRadius: 4,
          pointHitRadius: 10,
          spanGaps: false,
          lineTension: 0,
          borderColor: 'rgba(255, 206, 86, 1)',
          borderColor: 'rgba(54, 162, 235, 1)',
          data: gon.test_order.items[1][1]
        },
         {
           label: gon.test_order.items[2][0],
           fill: false,
           backgroundColor: "rgba(255, 206, 86, 0.8)",
           borderCapStyle: 'butt',
           borderDash: [],
           borderDashOffset: 0.0,
           borderJoinStyle: 'miter',
           pointBorderColor: "rgba(255, 206, 86,1)",
           pointBackgroundColor: "#fff",
           pointBorderWidth: 1,
           pointHoverRadius: 5,
           pointHoverBackgroundColor: "rgba(255, 206, 86,1)",
           pointHoverBorderWidth: 1,
           pointRadius: 4,
           pointHitRadius: 10,
           lineTension: 0,
           spanGaps: false,
           borderColor: 'rgba(255, 206, 86, 1)',
           data: gon.test_order.items[2][1]
          },
        {
            label: gon.test_order.items[3][0],
            fill: false,
            backgroundColor: "rgba(204, 204, 204, 0.8)",
            borderColor: "rgba(204, 204, 204, 0.8)",
            borderCapStyle: 'butt',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(204, 204, 204,1)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            lineTension: 0,
            pointHoverBackgroundColor: "rgba(204, 204, 204,1)",
            pointHoverBorderWidth: 1,
            pointRadius: 4,
            pointHitRadius: 10,
            spanGaps: false,
            data: gon.test_order.items[3][1]
        },
        {
            label: gon.test_order.items[4][0],
            fill: false,
            backgroundColor: "rgba(75,192,192,0.8)",
            borderColor: "rgba(75,192,192,0.8)",
            borderCapStyle: 'butt',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(75,192,192,1)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            lineTension: 0,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(75,192,192,1)",
            pointHoverBorderWidth: 1,
            pointRadius: 4,
            pointHitRadius: 10,
            data: gon.test_order.items[4][1],
            spanGaps: false,
        },
        {
            label: gon.test_order.items[5][0],
            fill: false,
            backgroundColor: "rgba(140, 72, 159, 0.8)",
            borderColor: "rgba( 140, 72, 159, 0.8)",
            borderCapStyle: 'butt',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(140, 72, 159,1)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            lineTension: 0,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(140, 72, 159,1)",
            pointHoverBorderWidth: 1,
            pointRadius: 4,
            pointHitRadius: 10,
            spanGaps: false,
            data: gon.test_order.items[5][1]
        },
      ],
    }
    new Chart(ctx, {
      type: 'line',
      data: lineChartData,
      options: {
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero: true,
              stepSize: 1,
              callback: function(tickValue, index, ticks) {
                if(!(index % parseInt(ticks.length / 10))) {
                  return tickValue
                }
              }
            }
          }]
        }
      }
    });

    ctx = document.getElementById("test_cases_status_calculating_chart");
    lineChartData = {
      labels: gon.test_results.labels,
      datasets: [
        {
          label: gon.test_results.items[0][0],
          fill: false,
          backgroundColor: "rgba(75,192,192,0.8)",
          borderColor: "rgba(75,192,192,0.8)",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(75,192,192,1)",
          pointBackgroundColor: "#fff",
          pointBorderWidth: 1,
          lineTension: 0,
          pointHoverRadius: 5,
          pointHoverBackgroundColor: "rgba(75,192,192,1)",
          pointHoverBorderWidth: 1,
          pointRadius: 4,
          pointHitRadius: 10,
          spanGaps: false,
          data: gon.test_results.items[0][1]
        },
        {
          label: gon.test_results.items[1][0],
          fill: false,
          backgroundColor: "rgba(78, 92, 78, 0.8)",
          borderColor: "rgba(78, 92, 78, 0.8)",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(78, 92, 78, 1)",
          pointBackgroundColor: "#fff",
          pointBorderWidth: 1,
          pointHoverRadius: 5,
          pointHoverBackgroundColor: "rgba(78, 92, 78, 1)",
          pointHoverBorderWidth: 1,
          pointRadius: 4,
          pointHitRadius: 10,
          lineTension: 0,
          spanGaps: false,
          borderColor: 'rgba(78, 92, 78, 1)',
          data: gon.test_results.items[1][1]
        },
        {
          label: gon.test_results.items[3][0],
          fill: false,
          backgroundColor: "rgba(54, 162, 235, 0.8)",
          borderColor: "rgba(54, 162, 235, 0.8)",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(54, 162, 235,1)",
          pointBackgroundColor: "#fff",
          pointBorderWidth: 1,
          pointHoverRadius: 5,
          pointHoverBackgroundColor: "rgba(54, 162, 235,1)",
          pointHoverBorderWidth: 1,
          pointRadius: 4,
          pointHitRadius: 10,
          spanGaps: false,
          lineTension: 0,
          borderColor: 'rgba(255, 206, 86, 1)',
          borderColor: 'rgba(54, 162, 235, 1)',
          data: gon.test_results.items[3][1]
        },
        {
          label: gon.test_results.items[4][0],
          fill: false,
          backgroundColor: "rgba(255, 99, 132, 0.8)",
          borderColor: "rgba(255, 99, 132, 0.8)",
          borderCapStyle: 'butt',
          borderDash: [],
          borderDashOffset: 0.0,
          borderJoinStyle: 'miter',
          pointBorderColor: "rgba(255, 99, 132,1)",
          pointBackgroundColor: "#fff",
          pointBorderWidth: 1,
          pointHoverRadius: 5,
          pointHoverBackgroundColor: "rgba(255, 99, 132,1)",
          pointHoverBorderWidth: 1,
          pointRadius: 4,
          pointHitRadius: 10,
          lineTension: 0,
          spanGaps: false,
          borderColor: 'rgba(255, 99, 132, 1)',
          data: gon.test_results.items[4][1]
        }
      ],
    };
    new Chart(ctx, {
      type: 'line',
      data: lineChartData,
      options: {
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero: true,
              stepSize: 1,
              callback: function(tickValue, index, ticks) {
                if(!(index % parseInt(ticks.length / 10))) {
                  return tickValue
                }
              }
            }
          }]
        }
      }
    });
  }
}
