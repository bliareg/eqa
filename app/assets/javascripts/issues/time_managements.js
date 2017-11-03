function update_issue_spent_time_count(count, issue_id) {
  $('.modal-tabs-list .spent-time-count').text(count);
  $('.agile_card[data-issue-id=' + issue_id + '] p.state').text(count);
}

var editingTimeManagement = false;

function init_spent_time_tab() {
  if ($._data( $('.spent-time-tab .save_btn')[0], 'events' )) { return }

  $('#new_time_management').submit(function (e) {
    if (editingTimeManagement.length) {
      e.preventDefault();
      e.stopImmediatePropagation();

      $('.spent-time-tab .save_btn').click();
    }
  });

  $(document).on('click', '.destroy_spent_time_btn', function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    if (confirm('Are you sure?')) {
      id = $(this).parents('tr').data('time-management-id');
      $(this).parents('tr').remove();

      $.ajax({
        url: '/time_managements/' + id,
        method: 'DELETE'
      });

      if ($('.spent-time-tab .save_btn').is(':visible')) { view_mode(); }
    }
  });

  $(document).on('click', '.edit_spent_time_btn', function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    if ($('.spent-time-tab .save_btn').is(':visible')) { view_mode(); }

    spent_time = $(this).parents('td').siblings('.col-spent-time')
                                      .children().text();
    $('#time_management_spent_time').val(spent_time);

    comment = $(this).parent().parent('td').siblings('.col-comment').text();
    $('#time_management_comment').val(comment)

    $('.spent-time-tab form .tab-header').addClass('tab-header-edit');
    $('.spent-time-tab form input.btn').hide();
    $('.spent-time-tab .save_btn, .spent-time-tab .cancel_btn').show();

    editingTimeManagement = $(this).parents('tr');
    editingTimeManagement.addClass('edit-field');
  });

  $('.spent-time-tab .cancel_btn').click(function() {
    view_mode();
  });

  $('.spent-time-tab .save_btn').click(function() {
    spent_time = $('#time_management_spent_time').val();

    if (spent_time.length) {
      comment = $('#time_management_comment').val();

      id = editingTimeManagement.data('time-management-id');
      $.ajax({
        url: '/time_managements/' + id,
        method: 'PUT',
        data: { time_management: { spent_time: spent_time, comment: comment } },
        success: function() {
          editingTimeManagement.find('.col-spent-time').children().text(spent_time);
          editingTimeManagement.find('.col-comment').text(comment);
          view_mode();
        },
        error: function(request, status) {
          ajaxErrorValidation(request, $('#new_time_management'));
        }
      });
    }
  });

  function view_mode() {
    $("#new_time_management .input_wrapper input[type='text']").val('');

    $('.spent-time-tab form .tab-header').removeClass('tab-header-edit');
    $('.spent-time-tab form input.btn').show();
    $('.spent-time-tab .save_btn, .spent-time-tab .cancel_btn').hide();
    editingTimeManagement.removeClass('edit-field');
    editingTimeManagement = false;
  }
}
