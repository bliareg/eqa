function init_change_roles() {
  changes = {};
  changes.roles = {};

  if ($('#invitation_modal').length) {
    // json data creation with check or uncheck all
    change_multiple_roles();
    // json data creation with input tag(check-uncheck)
    change_single_role();
    // json data creation with select tag removed to main.js
    applying_changes();
  }
}


$(document).on('click', 'table .delete-org-role', function() {
  organization = $('.org-members-table').data('organization');
  user = user_id=$(this).data('user');
  var that = $(this);
  if (confirm('Are you sure?')) {
    $.ajax({
      type: 'DELETE',
      data: {organization_id: organization, user_id: user},
      url: '/organizations/members/delete_member_role',
      success: function (data) {
        that.closest('tr').next().remove();
        that.closest('tr').remove();
        $('td.members-count span').text($('tr.member').length);
        count_members = $('.count-active')[1].innerText-1 
        if (count_members < 10) 
        $('.count-active')[1].innerText = "0" + count_members;
        else  $('.count-active')[1].innerText-=1;
        alert(data.text);
      }
    });    
  }
});

$(document).on('click', 'table .delete-proj-role', function() {
  project_id=$(this).data('project');
  user_id=$(this).closest('table').data('user');
  changes.roles[user_id] = { role: '',
                             operation: false };
  var that = $(this);
  
  $.ajax({
    type: 'POST',
    data: changes,
    url: '/projects/' + project_id + '/add_members',
    success: function () {
      var projects_table = that.parents('td.org-projects-table-wrap');
      that.parents('tr.org-project').remove();
      var project_roles_count = projects_table.find('tr.org-project').length
      $('tr.member[member=' + user_id + '] td.member-projects').text(project_roles_count)
      if (project_roles_count == 0){
        projects_table.parent().remove();
      }
    }
  });
});

function change_multiple_roles(){
  $('#invitation_modal table').on('click', 'tr.table-title td #checkbox', function(e) {
    $('#invitation_modal table tr.member td .checkbox').each(function(){
      if ( ($(this).prop('checked') != $('#checkbox').prop('checked')) && !$(this).prop('disabled')) {
        $(this).prop('checked', $('#checkbox').prop('checked')).trigger('change');
      }
    })
  })
}

function change_single_role(){
  $('#invitation_modal table').on('change', 'tr.member td .checkbox', function(e) {
    var user_id = $(this).attr('user');
    push_data_to_changes_hash(user_id)
  });
  $('#invitation_modal table').on('click', 'tr.member td input', function(e) {
    check_box_title();
  });
}

function push_data_to_changes_hash(user_id) {
  select_selector = '#checkbox_' + user_id;
  if ($(select_selector).prop('checked') == false && changes.roles[user_id]) {
    delete changes.roles[user_id];
  } else {
    changes.roles[user_id] = log_changes($(select_selector));
  }
}

function log_changes(checkbox) {
  user_id = checkbox.attr('user');
  select_selector = 'div#' + user_id;
  option = select_selector + ' input';
  operation = checkbox.prop('checked');
  return {
    role: $(option).attr('value'),
    operation: operation
  };
}

function check_box_title() {
  var i = $('#invitation_modal table tr.member td input:checked').length;
  if ($('#invitation_modal table tr.member td .checkbox').length == i ) {
    $('#invitation_modal table tr.table-title td input').prop('checked', true);
  } else {
    $('#invitation_modal table tr.table-title td input').prop('checked', false);
  }
}

function applying_changes(){
  $('#send').on('click', function(e) {
    project_id = $('#invitation_modal').data('project');
    changes.show_list = $(this).attr('show_list')
    $.ajax({
      type: 'POST',
      data: changes,
      url: '/projects/' + project_id + '/add_members',
      success: function () {
        disappear_modal();
      }
    });
  });
}
