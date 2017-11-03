$(document).ready(function() {
  init_project_overview_diagram();
});

function init_project_overview_diagram() {
  if ($('div').is('.overview-chart')) {
    var context = $('#project_overview_diagram');
    var test_objects_data =  {
                              label: gon.labels[0],
                              fill: false,
                              lineTension: 0,
                              backgroundColor: "rgb(40, 189, 139)",
                              borderColor: "rgb(40, 189, 139)",
                              borderCapStyle: 'butt',
                              borderWidth: 0.0,
                              borderDash: [],
                              borderDashOffset: 0.0,
                              borderJoinStyle: 'miter',
                              pointBorderColor: "rgb(40, 189, 139)",
                              pointBackgroundColor: "#fff",
                              pointBorderWidth: 1,
                              pointHoverRadius: 5,
                              pointHoverBackgroundColor: "rgb(40, 189, 139)",
                              pointHoverBorderColor: "rgb(40, 189, 139)",
                              pointHoverBorderWidth: 2,
                              pointRadius: 1,
                              pointHitRadius: 10,
                              data: gon.test_objects_per_day,
                              spanGaps: false
                            }
    var test_cases_data = {
                            label: gon.labels[1],
                            fill: false,
                            lineTension: 0,
                            borderWidth: 0.0,
                            backgroundColor: "rgb(58, 108, 250)",
                            borderColor: "rgb(58, 108, 250)",
                            borderCapStyle: 'butt',
                            borderDash: [],
                            borderDashOffset: 0.0,
                            borderJoinStyle: 'miter',
                            pointBorderColor: "rgb(58, 108, 250)",
                            pointBackgroundColor: "#fff",
                            pointBorderWidth: 1,
                            pointHoverRadius: 5,
                            pointHoverBackgroundColor: "rgb(58, 108, 250)",
                            pointHoverBorderColor: "rgb(58, 108, 250)",
                            pointHoverBorderWidth: 2,
                            pointRadius: 1,
                            pointHitRadius: 10,
                            data: gon.test_cases_per_day,
                            spanGaps: false
                          }
    var issues_data = {
                        label: gon.labels[2],
                        fill: false,
                        lineTension: 0,
                        borderWidth: 0.0,
                        backgroundColor: "rgb(250, 166, 58)",
                        borderColor: "rgb(250, 166, 58)",
                        borderCapStyle: 'butt',
                        borderDash: [],
                        borderDashOffset: 0.0,
                        borderJoinStyle: 'miter',
                        pointBorderColor: "rgb(250, 166, 58)",
                        pointBackgroundColor: "#fff",
                        pointBorderWidth: 1,
                        pointHoverRadius: 5,
                        pointHoverBackgroundColor: "rgb(250, 166, 58)",
                        pointHoverBorderColor: "rgb(250, 166, 58)",
                        pointHoverBorderWidth: 2,
                        pointRadius: 1,
                        pointHitRadius: 10,
                        data: gon.issues_per_day,
                        spanGaps: false
                      }
    var crashes_data =  {
                          label: gon.labels[3],
                          fill: false,
                          lineTension: 0,
                          backgroundColor: "rgb(236, 70, 70)",
                          borderWidth: 0.0,
                          borderColor: "rgb(236, 70, 70)",
                          borderCapStyle: 'butt',
                          borderDash: [],
                          borderDashOffset: 0.0,
                          borderJoinStyle: 'miter',
                          pointBorderColor: "rgb(236, 70, 70)",
                          pointBackgroundColor: "#fff",
                          pointBorderWidth: 1,
                          pointHoverRadius: 5,
                          pointHoverBackgroundColor: "rgb(236, 70, 70)",
                          pointHoverBorderColor: "rgb(236, 70, 70)",
                          pointHoverBorderWidth: 2,
                          pointRadius: 1,
                          pointHitRadius: 10,
                          data: gon.crashes_per_day,
                          spanGaps: false
                        }
    var data = {
                  labels: gon.data_labels,
                  datasets: [
                              test_objects_data,
                              test_cases_data,
                              issues_data,
                              crashes_data
                            ]
                };

    new Chart.Line(context, {
      data: data,
      options: {
        legend: {
                  fullWidth: true,
                  labels: { fontSize: 12 }
                },
        title:  {
                  display: true,
                  fontSize: 16,
                  text: gon.graph_name
                },
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
