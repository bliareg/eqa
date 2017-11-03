$(document).ready(function() {
  init_root_diagram();
});

function init_root_diagram() {
  if ($('div').is('.Home')) {
    var context = document.getElementById('root_diagram').getContext('2d');
    var barChartData = {
      labels: gon.titles,
      datasets: [{
        label: gon.labels[0],
        backgroundColor: "rgba(54, 162, 235, 0.8)",
        borderColor: "rgba(54, 162, 235, 0.8)",
        data: gon.test_objects
      }, {
        label: gon.labels[1],
        backgroundColor: "rgba(0, 153, 76, 0.6)",
        borderColor: "rgba(0, 153, 76, 0.6)",
        data: gon.test_cases
      }, {
        label: gon.labels[2],
        backgroundColor: "rgba(255, 99, 132, 0.8)",
        borderColor: "rgba(255, 99, 132, 0.8)",
        data: gon.test_crashes
      }, ],
    }
    new Chart(context, {
      type: 'bar',
      data: barChartData,
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
