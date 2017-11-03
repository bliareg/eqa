var TestRunResult = {
  init_sortable: function() {
    $('.result_sortable').sortable({
      cursor: "move",
      handle: '.drag-icon',
      revert: true,
      stop: TestRunResult.update_positions
    }).disableSelection();
  },

  update_positions: function() {
    test_run_id = $(this).parents('.testRun-test-info').data('test-run-id');

    results_positions = {};
    $(this).find('tr').each(function(i) {
      results_positions[$(this).data('test-result-id')] = i
    });

    $.ajax({
      type: 'PUT',
      url: '/test_run_result_positions/' + test_run_id,
      data: {
        test_run_result_positions: results_positions
      }
    })
  }
}