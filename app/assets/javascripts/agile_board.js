var project_id

function issues_agile_board_init() {
  if ( $('.issue_inner').length == 0) {
    return;
  }
  project_id = $('.agile').data('project-id');

  issue_filter_actions();
  add_push_up_notifications_subscribe();
  initialize_scroll_bar();
  manage_statuses();
  column_visibility_slide();
  scroll_agile_board();

  $('.agile_content').sortable({
    connectWith: ".connectedSortable",
    cursor: "move",
    revert: true,
    receive: stoped_sortable_issue,
    start: function() {
      $('.agile_card').removeClass('active');
    }

  }).disableSelection();

  function stoped_sortable_issue(event, ui) {
    if (ui.item.parents('.connectedSortable').length == 0) return;

    var status_id = $(this).siblings('.agile_title').data('status-id');
    var issue_id = ui.item.data('issue-id');

    var sender_count = ui.sender.siblings('.agile_title').find('.count');
    sender_count.text(parseInt(sender_count.text()) - 1);

    var receiver_count = $(this).siblings('.agile_title').find('.count');
    receiver_count.text(parseInt(receiver_count.text()) + 1);
    $.ajax({
      type: 'PUT',
      data: { issue: { status_id: status_id } },
      url: '/projects/' + project_id + '/issues/' + issue_id
    });
  }

  $(document).on('click', '.agile_card', function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    if ($(this).hasClass('active')){
      issue_id = $(this).data('issue-id');
      project_issue_number = parseInt($(this).find('p.id span').text());
      current_url = window.location.href
      if (!current_url.match(/[?&]issue_id/)){
        add_query_params(current_url, project_issue_number);
        open_issue(issue_id)
      }
    } else {
      $('.agile_card').removeClass('active');
      $(this).addClass('active');
    }
  });
}

function add_query_params(current_url, project_issue_number){
  if (current_url.match(/\?/)){
    issue_params = '&issue_id=' + project_issue_number
  } else {
    issue_params = '?issue_id=' + project_issue_number
  }
  history.pushState('', '', window.location.href + issue_params);
}

function open_issue(issue_id){
  $.ajax({
    type: 'GET',
    url: 'issues/' + issue_id,
    success: function(data) {
      $(MODAL_CLASS).html(data.html);
      show_modal();
      custom_select();
      init_new_issue_dropzone();
      initialize_tabs();
      initialize_scroll_bar();
      init_issue_info();
    }
  });
}

function clear_query_params(){
  var url = window.location.href;
  url = url.replace(/[?&]issue_id=\d*/, '').replace(/[?&]+$/, '')
  window.history.pushState('dashboard', '', url);
}

function manage_statuses() {
  $('.head_title_bottom .add-column').click(function (e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    $.ajax({
      url: '/projects/' + project_id + '/statuses',
      method: 'POST'
    })
  });

  $('.agile_title').on('dblclick', function (e) {
    input_wrapper = $(this).children('.input_wrapper')
    if (input_wrapper.length) {
      $(this).children('span').hide();
      input_wrapper.show();
      input_wrapper.find('input').focus();
      input_wrapper.find('input').select();
    }
  });

  $('.agile_title .input_wrapper input').on('focusout', function () {
    status_id = $(this).parents('.agile_title').data('status-id');
    status_name = $(this).val()
    show_status_title($(this));

    $.ajax({
      url: '/projects/' + project_id + '/statuses/' + status_id,
      method: 'PUT',
      data: { status: { name: status_name }}
    });
  });

  status_sortable();
  delete_status_area();
  $('.change-bg-btn').on('click', openColorPicker);
  $('.color-picker .color-list li').on('click', change_color);
}

function show_status_title(status_input) {
  status_title = status_input.parent().siblings('span');
  counter = status_title.find('.count').text();

  status_title.html(status_input.val()
                                .replace(/\</g, '&lt')
                                .replace(/\>/g,'&gt') + " (<span class='count'>" + counter + '</span>)');
  status_title.show();
  status_input.parent().hide();
}

function status_sortable() {
  $('.issue_content .agile').sortable({
    items: '> .agile_bord',
    handle: '.agile_title',
    revert: true,
    opacity: 0,
    tolerance: 'pointer',
    containment: '.issue_inner',
    appendTo: '.issue_content',
    stop: update_status_position,
    helper: function (e, item) {
      helper = $("<div class='agile'></div>");
      clone = item.clone();
      return helper.append(clone);
    },
    start: function (e, ui) {
      if (ui.item.find('.agile_title').children('.input_wrapper').length) {
        $('.remove-column').show();
        $('.add-column').hide();
      }
    }
  });
}

function update_status_position() {
  positions = {}
  $('.agile_bord').each(function (i){
    status_id = $(this).find('.agile_title').data('status-id');
    positions[status_id] = i;
  })
  scroll_agile_board();
  $.ajax({
    method: 'PUT',
    url: '/projects/' + project_id + '/positions',
    data: { positions: positions }
  });
  $('.remove-column').hide();
  $('.add-column').show();
}

function delete_status_area() {
  $('.remove-column').droppable({
    accept: '.agile_bord',
    tolerance: 'pointer',
    hoverClass: 'hover',
    drop: function (e, ui){
      status_item = ui.draggable
      status_id = status_item.find('.agile_title').data('status-id');
      move_issues_to_submitted(status_item);
      ui.helper.remove();
      status_item.remove();
      $('.issue_content').mCustomScrollbar('update');

      $.ajax({
        method: 'DELETE',
        async: false,
        url: '/projects/' + project_id + '/statuses/' + status_id
      });
    }
  });

  function move_issues_to_submitted(status_item) {
    submitted_title = $('.agile_title[data-status-id="1"]')
    if (submitted_title.length) {
      issues = status_item.find('.agile_card');
      submitted_title.siblings('.agile_content').append(issues);
      count = submitted_title.find('.count')
      count.text(parseInt(count.text()) + issues.length);
    }
  }
}

function openColorPicker(e) {
  e.preventDefault();
  e.stopImmediatePropagation();

  $target = $(e.target);
  $button = $('.change-bg-btn');
  $colorPicker = $('.color-picker');
  if ($('.agile_bord .color-picker').length) {
    close_color_picker($colorPicker);
  } else {
    $colorPicker.addClass("open-picker");
    $target.closest($button).after($colorPicker);
    active_color = this.className.match(/[0-9]/)[0];
    $colorPicker.find('.item-' + active_color).parent('li').addClass('active');
  }
}

function change_color(e) {
  e.preventDefault();
  e.stopImmediatePropagation();

  $colorPicker = $('.color-picker');
  old_color = $colorPicker.find('li.active span')[0].className.match(/[0-9]/)[0]
  $colorPicker.find('li').removeClass('active');
  $(this).addClass('active');

  active_color = $(this).children()[0].className.match(/[0-9]/)[0];

  change_btn = $colorPicker.siblings('.change-bg-btn');
  change_btn.removeClass('change-bg-' + old_color);
  change_btn.addClass('change-bg-' + active_color);

  agile_content = $colorPicker.siblings('.agile_content');
  agile_content.removeClass('column-bg-' + old_color);
  agile_content.addClass('column-bg-' + active_color);

  project_status_id = $colorPicker.parents('.agile_bord')
                                  .data('project-status-id');
  close_color_picker($colorPicker);

  $.ajax({
    method: 'PUT',
    url: '/projects/' + project_id + '/project_statuses/' + project_status_id,
    data: { project_status: { color: active_color }}
  });
}

function close_color_picker($colorPicker) {
  $defaultPosition = $('.main-footer');
  $defaultPosition.after($colorPicker);
  $colorPicker.removeClass("open-picker");
  $colorPicker.find('li').removeClass('active');
}

function column_visibility_slide() {
  $('.open-columns-list').on('click', function (e) {
    e.preventDefault();
    e.stopImmediatePropagation();

    $columnsList = $('.columns-list');
    $dropArrow = $('.open-columns-list .drop-arrow');


    if ($dropArrow.hasClass('arrow-up')) {
      $dropArrow.removeClass('arrow-up');
      $columnsList.slideUp('fast');
      $('.columns-list li').remove();
    } else {
      $dropArrow.addClass('arrow-up');
      add_show_column_list();
      $columnsList.slideDown('fast');
    }

  });

  $(document).on('change', '.issue_inner .columns-list input:checkbox', function(e){
    e.preventDefault();
    e.stopImmediatePropagation();

    project_status_id = parseInt($(this).attr('id').replace('show_columns_', ''));
    $.ajax({
      method: 'PUT',
      url: '/projects/' + project_id + '/project_statuses/' + project_status_id,
      data: { project_status: { show: $(this).prop('checked') }}
    });

    $('.agile_bord[data-project-status-id=' + project_status_id + ']').toggle();
    $('.issue_content .mCSB_container').width(1000);
    scroll_agile_board();
    $('.issue_content').mCustomScrollbar('update');
  });

  function add_show_column_list() {
    columns_list = $('.columns-list .mCSB_container')

    $('.agile_bord').each(function () {
      project_status_id = $(this).data('project-status-id');
      name = $(this).find('.agile_title').children('span').text()
                    .replace(/\</g, '&lt').replace(/\>/g,'&gt').split('\n')[0]
      checked = $(this).is(':visible')
      columns_list.append(show_column_item(name, project_status_id, checked))
    });
    $('.modal-content-scroll').mCustomScrollbar('update');
  }

  function show_column_item(name, id, checked) {
    item = $('<li> \
      <input type="checkbox" class="checkbox" id="show_columns_' + id + '"> \
      <label for="show_columns_' + id + '" class="checkbox-label">' + name + '</label> \
    </li>')

    if (checked) {
      item.find('input:checkbox').attr('checked', true)
    };
    return item
  }
}

function issue_filter_actions() {
  $('.filters').on('click', activeBtn);
}
