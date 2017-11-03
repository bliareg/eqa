$(document).on('click', '.cases-info-item-inner .cases-clikable.test_case_item td:not(.checkbox)', function() {
  id = $(this).parent().find('td.id').attr('case_id');
  show_test_case(id);
});

function show_test_case(id) {
  $.ajax({
    url: '/test_cases/' + id,
    success: function(data) {
      $(MODAL_CLASS).html(data.html);
      show_modal();
      bind_custom_scrollbar();
    }
  });
}

function test_case_nested_checkboxes(test_case_checkbox_selector, module_checkbox_selector) {
  $(document).on('change', module_checkbox_selector, function(){
    var test_cases = $(this).parents('thead')
                            .siblings('tbody')
                            .find('.test_case_item');

    var is_checked = $(this).prop('checked');
    test_cases.find('td input:checkbox').prop('checked', is_checked);
    test_cases.removeClass('row-checked');

    if (is_checked) {
      test_cases.addClass('row-checked');
      $(this).parents('tr').addClass('row-checked');
    } else {
      $(this).parents('tr').removeClass('row-checked');
    };
  });

  $(document).on('change', test_case_checkbox_selector, function(){
    var case_in_module = $(this).parents('.test_case_item')
                                .siblings('.test_case_item')
                                .add($(this).parents('.test_case_item'));
    var module_checkbox = case_in_module.parents('tbody')
                                        .siblings('thead')
                                        .find('input:checkbox');
    test_case = $(this).parents('.test_case_item');
    if ($(this).prop('checked')) {
      test_case.addClass('row-checked');
    } else {
      test_case.removeClass('row-checked');
    }

    if (case_in_module.length == case_in_module.find('td .checkbox:checked').length ) {
      module_checkbox.prop('checked', true);
      module_checkbox.parents('tr').addClass('row-checked');
    } else {
      module_checkbox.prop('checked', false);
      module_checkbox.parents('tr').removeClass('row-checked');
    }
  });
}

$(document).on('click', '.export-cases', function() {
  var checkedCases = $('.test_case_item .checkbox:checked').parents('.test_case_item'),
      caseIds = [];
  if (checkedCases.length) {
    caseIds = checkedCases.map(function() {
      return $(this).attr('id').match(/\d+/)[0]
    }).get();
  }
  window.location.href = $(this).data('path') + '?' + $.param({ test_cases: caseIds });
});