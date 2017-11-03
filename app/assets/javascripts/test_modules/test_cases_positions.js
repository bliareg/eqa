function update_cases_position(case_table) {
  test_module_id = case_table.parents('.cases-info-item-inner').first().data('id');

  test_cases_positions = {};
  case_table.find('.test_case_item.cases-clikable').each(function(i) {
    test_cases_positions[$(this).attr('id').match(/\d+/)] = i
  });

  $.ajax({
    type: 'PUT',
    url: '/test_modules/test_cases_positions/' + test_module_id,
    data: {
      test_cases_positions: test_cases_positions
    }
  })
}