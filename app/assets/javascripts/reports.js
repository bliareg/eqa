function InitializeCanvas(canvas, labels, label, results, backgroundColors, borderColors) {
  var myChart = new Chart(canvas, {
    type: 'pie',
    data: {
        labels: labels,
        datasets: [{
            label: label,
            data: results,
            borderWidth: 1,
            options: { responsive: true },
            backgroundColor: backgroundColors,
            borderColor: borderColors
        }]
    },
    options: {
      legend: {
        display: true,
        labels: {
          fontSize: 12
        }
      }
    }
  });
}

function drawCanvas(reports) {
  $('canvas').remove();
  reports.forEach(function (report, i) {
    report['canvas'] = $('<canvas></canvas>')[0];
    $('.chart').eq(i).append(report['canvas']);
    InitializeCanvas(
      report['canvas'],
      report['labels'],
      report['label'],
      report['results'],
      report['backgroundColors'],
      report['borderColors']
    );
  });
}

function init_test_reports() {
  var main_selector = '#report-type',
      secondary_selectors = '#test-run-report, #test-plan-report, #user-report',
      report_button = $('#report-button'),
      project_id = $('.test-reports-item').data('project-id');

  create_main_select();
  create_test_plan_report_select();
  create_test_run_report_select();
  create_user_report_select();

  $(secondary_selectors).hide();
  $(secondary_selectors).siblings('label').hide();
  document.getElementById("second_selectors").style.display = 'block';
  report_button.click(function(e){
    e.preventDefault();
    e.stopImmediatePropagation();

    $.ajax({
      url: $(this).attr('path'),
      success: function (data) {
        $('.preview-report').html(data.html);
      }
    });
  });

  function create_main_select() {
    generate_fake_input();
    $(main_selector).ddslick({
      width: "100%",
      background: "#fff",
      onSelected: function(data) {
        $(secondary_selectors).hide();
        $(secondary_selectors).siblings('label').hide();
        $('#test-run-report').ddslick('select', { index: 0 });
        $('#test-plan-report').ddslick('select', { index: 0 });
        $('#user-report').ddslick('select', { index: 0 });
        report_button.removeClass('btn-nonActive');

        if (data.selectedData.value.length == 0) {
          report_button.addClass('btn-nonActive');
        } else if (secondary_selectors.includes(data.selectedData.value)) {
          $('#' + data.selectedData.value).show();
          $('#' + data.selectedData.value).siblings('label[for=' + data.selectedData.value + ']').show();
          report_button.addClass('btn-nonActive');
        } else {
          report_button.attr('path', data.selectedData.value);
        }
      }
    });
  }

  function create_test_plan_report_select() {
    $('#test-plan-report').ddslick({
      width: "100%",
      background: "#fff",
      onSelected: function(data) {
        report_button.removeClass('btn-nonActive');
        if (data.selectedData.value.length == 0) {
          report_button.addClass('btn-nonActive');
        } else {
          report_button.attr('path', '/test_reports/TestPlan/'+ data.selectedData.value + '/TestCase');
        }
      }
    });
  }

  function create_test_run_report_select() {
    $('#test-run-report').ddslick({
      width: "100%",
      background: "#fff",
      onSelected: function(data) {
        report_button.removeClass('btn-nonActive');

        if (data.selectedData.value.length == 0) {
          report_button.addClass('btn-nonActive');
        } else {
          report_button.attr('path', '/test_reports/TestRun/'+ data.selectedData.value + '/TestRunResult');
        }
      }
    });
  }

  function create_user_report_select() {
    $('#user-report').ddslick({
      width: "100%",
      background: "#fff",
      onSelected: function(data) {
        report_button.removeClass('btn-nonActive');
        if (data.selectedData.value.length == 0) {
          report_button.addClass('btn-nonActive');
        } else {
          path = '/test_reports/User/'+ data.selectedData.value +
                 '/TimeManagement?project_id=' + project_id +
                 '&report_type=issue_type';
          report_button.attr('path', path);
        }
      }
    });
  }  
}

function name_and_report_type() {   
  name = ''
  if($('#test-run-report')[0].style.display == "block") { name = $('#test-run-report')[0].innerText }    
  if($('#test-plan-report')[0].style.display == "block") { name = $('#test-plan-report')[0].innerText }
  if($('#user-report')[0].style.display == "block") { name = $('#user-report')[0].innerText }
  report_type = $('#report-type')[0].innerText
}

function generate_pdf() {
  $('.download-pdf').click(function() { 
    name_and_report_type()
    element = $(this).parent('.preview-wrap').first();
    downloadReport(element, report_type, name);
  });

  $('.print-reports').click(function() {
    name_and_report_type()
    element = $(this).parent('.preview-wrap').first();
    printReport(element);
  });

  $('.send-email').click(function() {
    name_and_report_type()
    element = $(this).parent('.preview-wrap').first();
    sendEmail(element, report_type, name);
  });

  function sendEmail(element, report_type, name) {
    prepareReport(element, function() {
      $.ajax({
        type: 'POST',
        url: '/test_reports/send_email',
        data: { report_html: element.html(),
                report: report_type,
                report_name: name },
        success: function(data) {
          $('body').append(data.html);
        }
      });
    })
  }

  function downloadReport(element, report_type, name) {
    prepareReport(element, function() {
      $.ajax({
        type: 'POST',
        url: '/test_reports',
        data: { report_html: element.html(),
                report: report_type,
                report_name: name },
        success: function(data) {
          link = $('<a href="/' + data.path + '" download>link</a>')
          $('body').append(link);
          link[0].click();
          link.remove();
        }
      });
    })
  }

function prepareReport(element, action) {
  var images = [], canvas = element.find('canvas'), image;
    canvas.each(function(){
      image = $('<img src="' + this.toDataURL() + '">');
      $(this).after(image);
      images.push(image);
    })
    action();
    images.forEach(function(img){
      img.remove();
    });
 }

  function printReport(element) {
   prepareReport(element, function() {
    element.print({
      stylesheet: '/css/print_reports.css'
    });
   }) 
  }
};
