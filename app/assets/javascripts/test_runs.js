var TestRun = {
  validation: {
    test_plan: function(message) {
      $('form').data('client-side-validations').validators['test_run[test_run_results_attributes]'] = {
        json_validate: [{ message: message }]
      }
      $('form :input:radio').on('change', function() {
        $('.json-validate').trigger('change_json_value');
      })
    }
  }
}

var testRunCases = [],
    visible_plans = [];

$(document).on('change', '#select_specific_test_cases', function() {
  $('.change-selection').show();
  $('.test-plan').hide();
  $('.json-validate').trigger('change_json_value');
});
$(document).on('change', '#include_all_test_cases', function() {
  $('.test-plan').show();
  $('.change-selection').hide();
  $('.json-validate').trigger('change_json_value');
});


$(document).on('click', ".close_selection_test_cases", function() {
  $(".modal-add-test-run .modal-select-cases").removeClass('modal-select-cases-show');
});

$(document).on('click', ".change-selection .change", function () {
  if ($('#selectCases .modal-select-cases').length) {
    $(".modal-add-test-run .modal-select-cases").addClass("modal-select-cases-show");
  } else {
    var $form = $('#new_test_run, .edit_test_run'),
        project_id = $('#test_run_project_id').val(),
        test_plan_id = $('#testRunSelect .dd-selected-value').val(),
        test_run_id =  $(this).data('run-id');

    $.ajax ({
      url: '/projects/' + project_id + '/select_test_cases',
      method: 'post',
      data: { test_plan_id: test_plan_id, test_run_id: test_run_id },
      success: function(data) {
        testRunCases = data.results_array;
        $('#selectCases').html(data.html);
        $('#plan-id-' + test_plan_id).parent().addClass('active');
        visible_plans = [test_plan_id];

        if(testRunCases[test_plan_id]) {
          setTimeout(function() {
            testRunCases[test_plan_id].map(function(result_item) { $("#test-case-" + result_item['test_case_id']).click() })
          }, 100)
        }
      }
    });
  }
});

test_case_nested_checkboxes('input.module_checkbox:checkbox', 'input.checkbox-all:checkbox');
$(document).on('change', '.module_checkbox, .checkbox-all', function() {
  var module_id = $(this).data('module-id');
  if ($('#case-content-module-' + module_id + ' input.checkbox:checked').length == 0) {
    $('a#jstree-module-' + module_id + '_anchor').removeClass('jstree-checked');
  }
  else {
    $('a#jstree-module-' + module_id + '_anchor').addClass('jstree-checked');
  }
})

$(document).on('ajax:success', '#new_test_run, .edit_test_run', function(e, data){
  if ($(this).hasClass('edit_test_run')) {
    test_run_id = $(this).parent().data('test-run-id');
    if ($('.test_runs_list').length){
      $('#test-run-' + test_run_id).remove();
      $('.testRun-box.' + data.status + " .test_runs_list").prepend(data.html);
    } else {
      window.location.href = '/test_runs/' +  test_run_id
    }
  }
  else {
    $('.testRun-box.new .test_runs_list').prepend(data.html);
  }
  hide_modal();
});


$(document).on('click', '.test_run_test_plan_cart', function(e) {
  e.preventDefault();
  e.stopImmediatePropagation();
  var plan_id = $(this).data('plan-id'),
      project_id = $(this).data('project-id'),
      run_id = $(this).data('run-id'),
      module_container = $('.modules-for-plan-' + plan_id);

  if($(this).parent().hasClass('active')) {
    return;
  } else if (module_container.length){
    $('.plans-info-item').removeClass('active');
    $('#plan-id-' + plan_id).parent().addClass('active');
    $('.modules-and-cases').hide();
    module_container.show();
  } else {
    $.ajax({
      url: '/projects/' + project_id + '/select_modules',
      data: { test_plan_id: plan_id, test_run_id: run_id },
      method: 'post',
      success: function(data) {
        $('.plans-info-item').removeClass('active');
        $('#plan-id-' + plan_id).parent().addClass('active');
        $('.modules-and-cases').hide();
        $('.modules-and-cases').last().after(data.html);

        visible_plans.push(String(plan_id));
        jstree_test_run_init(plan_id);
        bind_custom_scrollbar();
        if (testRunCases[plan_id]) {
          testRunCases[plan_id].map(function(result_item) { $("#test-case-" + result_item['test_case_id']).click()});
        }
      }
    });
    testModuleWidth();
  }
})

$(document).on('click', '.save_select_cases', function() {
  test_run_results_attributes = retrieve_test_run_results_array();
  $('#select_specific_test_cases').val(JSON.stringify(test_run_results_attributes));
  $('.json-validate').trigger('change_json_value');

  $(".modal-add-test-run .modal-select-cases").removeClass('modal-select-cases-show');
  $('.modal-dialog:visible').not(':first').remove()

  item_length = test_run_results_attributes.filter(function (result_item) {
    return !result_item['_destroy']
  }).length;
  $('.change-selection span').text(item_length);
});

$(document).on('click', 'i.jstree-checkbox', function(e) {
  $('.cases-info-item-inner').addClass('open');
  $('.cases-info-item-inner .test-caret').addClass('caret-down');
  $('#checkbox-module-' + $(this).siblings('span').attr('data-id')).click()
});

$(document).on('click', '.checked-all-modules', function() {
  $('.modules-and-cases:visible li.jstree-node a.jstree-anchor').addClass('jstree-checked');
  $('.modules-and-cases:visible .cases-info-item-inner').addClass('open');
  $('.modules-and-cases:visible .cases-info-item-inner .test-caret').addClass('caret-down');

  $('.modules-and-cases:visible input.checkbox').prop('checked', true);
})

$(document).on('click', '.unchecked-all-modules', function() {
  $('.modules-and-cases:visible li.jstree-node a.jstree-anchor').removeClass('jstree-checked');
  $('.modules-and-cases:visible input.checkbox').prop('checked', false);
})

$(document).on('ajax:success', '.test_run_profile_button', function(e, data){
  hide_modal()
  if(data.html != null) {
    $('.tab-content').html(data.html);
    add_profile_table_links();
    if (data.gon_values.length != 0){
      BuildDiagram(data.gon_values, data.chart_labels);
    }
  } else {
    JsDataRender.test_run_profile.render_data(data) }
});

$(document).on('click', '.radio-status-result input', function() {
  var $this = $(this),
      result_id = $this.attr('data-result-id'),
      status = $this.val(),
      project_id = $this.data('project-id');
  $.ajax({
    url: '/projects/' + project_id + '/update_result_status',
    method: 'post',
    data: { result_id: result_id, status: status },
    success: function(data) {
      if($('input#radio5:checked').length > 0) {
        $(MODAL_CLASS).find('.modal-test-run-steps').css('display','none');
        $(MODAL_CLASS).append('<div class="double-modal" style="display:none"></div>')
        $(MODAL_CLASS).append(data.html)
        initialize_modal();
      }
    }
  })
})

$(document).on('click', '.edit_case', function(event) {
  var case_id = $(this).attr('case_id'),
      test_run_result_id = $(this).attr('test_run_result_id');
  $.ajax({
    url: '/test_cases/' + case_id + '/edit',
    method: 'get',
    data: { change_content: true, test_run_result_id: test_run_result_id },
    success: function(data) {
      $(MODAL_CLASS).find('.modal-test-run-steps').css('display','none');
      $(MODAL_CLASS).append('<div class="double-modal" style="display:none"></div>')
      $(MODAL_CLASS).append(data.html)
      initialize_modal();
    }
  })
})

$(document).on('ajax:success', '.delete_case', function() {
  result_id = $('.edit_case').attr('test_run_result_id')
  result_row = 'tr[data-test-result-id=' + result_id + ']'
  $(result_row).remove()
  var button;
  if ($('a.next-case').length > 0) {
    button = $('a.next-case');
  } else {
    button = $('a.test_run_profile_button');
  }
  button.click();
  change_module_counter()
})

function change_module_counter() {
  var items_count = $('items').length + 1;
  var sender_counts = $('.number')
  sender_counts.each(function(i, val) {
    var number_text = sender_counts[0].innerText;
    var number = parseInt(number_text.substring(1, number_text.length-1)) - items_count
    $(val).text('(' + number + ')')
  });
}

function BuildDiagram(values, labels){
  var context2 = document.getElementById('test_run_statuses_calculating_chart').getContext('2d');
  var data2 = {
      datasets: [{
          data: values,
          backgroundColor: [
              "#4CAF50",
              "#4E5C4E",
              "#E7E9ED",
              "#64b5f6",
              "#FF6384"
          ],
          label: 'My dataset' // for legend
      }],
      labels: labels
  };
  new Chart(context2, {
      data: data2,
      type: 'pie',
      options: { responsive: false }
  });
};

$(document).on('click', "#printLink", function() {
  printPage();
});

function printPage() {
  var dataUrl = document.getElementById('test_run_statuses_calculating_chart').toDataURL();
  var printContents = document.getElementById('printImage').innerHTML;
  var table = document.getElementsByClassName('testRun-test-info')[0].outerHTML;
  var windowContent = '<html>';
  windowContent += '<body><div>';
  windowContent += '<img src="' + dataUrl + '">';
  windowContent += "<p>" +printContents+ "</p>";
  windowContent += table;
  windowContent += '</div></body>';
  windowContent += '</html>';
  $(windowContent).print({
      stylesheet: '/css/print_test_run.css'
    });
}

$(document).on('ajax:success', '.btn-step.btn-prev, .btn-step.next-case', function(e, data) {
  $(MODAL_CLASS).html(data.html);
  bind_custom_scrollbar();
})

function replace_modal_to_execute_test_run() {
  $(MODAL_CLASS).find('.add_issue').remove();
  $(MODAL_CLASS).find('.modal-add-case').remove();
  $(MODAL_CLASS).find('.double-modal').remove();
  $(MODAL_CLASS).find('.modal-test-run-steps').show();
}

function add_profile_table_links() {
  $('.cases-test-content-item table tbody tr td:not(.drag-icon)').on('click', function() {
    $.ajax({
      url: '/test_run_results/' + $(this).parent().data('test-result-id'),
      dataType: 'script'
    });
  });
}

function retrieve_test_run_results_array() {
  case_ids = $(".checkbox.module_checkbox:checked").map(function(){ return $(this).val() }).get();
  array = [];
  $.each(testRunCases, function(test_plan_id, test_cases) {
    array.push(test_cases.map(function(result_item) {
      if ($.inArray(String(result_item['test_case_id']), case_ids) == -1 && $.inArray(String(test_plan_id), visible_plans) > -1) {
        result_item['_destroy'] = true
      } else {
        delete result_item['_destroy']
        index_of_element = case_ids.indexOf(String(result_item['test_case_id']))
        if (index_of_element > -1){
          case_ids.splice(index_of_element, 1)
        }
      }
      return result_item
    }));
  });

  array.push(case_ids.map(function(case_id){
    return { test_case_id: case_id }
  }));
  return [].concat.apply([], array);
}

function jstree_test_run_init(plan_id) {
  $jstreeCheckbox = $('#jstree_demo_div_popUp_' + plan_id);
  $jstreeCheckbox.jstree({
      "plugins": ["checkbox"],
      checkbox: {
        three_state : false, // to avoid that fact that checking a node also check others
        whole_node : false,  // to avoid checking the box just clicking the node
        tie_selection : false // for checking without selecting and selecting without checking
      }
  });
  $jstreeCheckbox.jstree('open_all');
}
