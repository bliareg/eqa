$(document).on('change', '.test_case_item td input:checkbox', function(){
  copy_cases_btn = $('.copy_cases');
  if ($('.test_case_item td input:checkbox:checked').length > 0) {
    if (copy_cases_btn.is(':hidden')) copy_cases_btn.show();
  } else {
    copy_cases_btn.hide();
  }
});

$(document).on('change', '.caseSortable thead input:checkbox', function(){
  module_id = $(this).parents('.cases-info-item-inner').data('id');
  copy_cases_btn = $('.copy_cases');
  selector = '.caseSortable thead:not(#module_' + module_id + ')';
  if ($(this).prop('checked')) {
    if (copy_cases_btn.is(':hidden')) copy_cases_btn.show();
  } else if ($(selector).next('tbody').find('.test_case_item td input:checkbox:checked').length == 0){
    copy_cases_btn.hide();
  }
});

$(document).on('click', '.copy_cases', function(){
  project_id = $('#projects-left-menu').data('project-id');
  $.ajax({
    url: '/projects/' + project_id + '/copy_test_cases/new',
    success: function() {
      $('.copy_cases_test_plan_cart').first().click();
    }
  });
});

$(document).on('click', '.copy_cases_to_module', function(){
  project_id = $('#projects-left-menu').data('project-id');
  selected_cases = $('.test_case_item td input:checkbox:checked').parent()
                    .siblings('.id').map(function() { return $(this).attr('case_id') })
                    .get();
  selected_modules = $('.copy-cases-info-modal .jstree-checked span')
                      .map(function() { return $(this).data('id') })
                      .get();
  $.ajax({
    url: '/projects/' + project_id + '/copy_test_cases',
    method: 'post',
    data: {
      test_cases_ids: selected_cases,
      test_modules_ids: selected_modules
    }
  });
});

$(document).on('click', '.copy_cases_test_plan_cart', function(){
  test_plan_id = $(this).data('plan-id');
  $('.plans-info-item.active').removeClass('active');
  $('.modules-and-cases').hide();

  $(this).parent().addClass('active');
  $('.modules-for-plan-' + test_plan_id).show();
});
