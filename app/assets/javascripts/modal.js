const MODAL_CLASS = '.modal'
var old_browser_path;
$(document).on('ready', function() {
  $(document).on('ajax:success', '.open_popup', function(e, data) {
    open_modal(data.html);
    if (typeof data === 'object' && 'title' in data ) {
      change_popup_title(data.title);
    }
  });
});

function open_modal(html, root_path, modal_path) {
  if (root_path) {
    old_browser_path = root_path;
  } else if (modal_path) {
    old_browser_path = window.location.pathname
    window.history.pushState({}, '', modal_path);
  }

  $(MODAL_CLASS).html(html);
  show_modal();
  initialize_modal();
}

function show_modal() {
  $(MODAL_CLASS).show();
  $("body").mCustomScrollbar("disable");
}

$(document).on('click', '.finish_import_button', function() {
  window.location.href = old_browser_path;
});

function hide_modal() {
  if (old_browser_path) {
    window.history.pushState({}, '', old_browser_path);
    highlight_project_left_menu_item(old_browser_path);
    add_active_to_test_plan_tab();
    old_browser_path = false;
  }
  $("body").mCustomScrollbar("update");
  $(MODAL_CLASS).hide();
}

function initialize_modal() {
  init_select_sync_plugin();
  custom_select();
  initialize_scroll_bar();
  init_new_organization_dropzone();
  init_new_project_dropzone();
  init_new_issue_dropzone();
  init_test_object_dropzone();
  build_link_inform_init();
  check_box_title();
  init_send_link_to_email();
  ddslick_direction();
  init_change_roles();
}

function disappear_modal() {
  $('div#error_message').html('');
  clear_query_params();
  hide_modal();
}

function init_popup_height() {
  if ($('.modal-content-scroll').length) {
    if ($(this).parents('.input_wrapper').length || $(this).css('max-height') != 'none') { return true; }
    modal_dialog_height = $(this).parents('.modal-dialog').height();

    content = $(this).find('.mCSB_container')
    if (content.is(':hidden')) {
      max_height = $(this).parents('.modal-dialog').find('.modal-content-scroll:visible').css('max-height')
      $(this).css({
        'max-height': max_height
      });
    } else {
      content_height = content.height();

      border_height = modal_dialog_height + 60 - content_height;
      height = ($(window).height() - border_height)
      $(this).css({
        'max-height': height
      });
    }
  }
}

$(document).on('click', '.modal-content .close, .modal-content .cancel', function() {
  if ($('.modal form').map(function(){ return $(this).data('changed') }).get().includes(true) && !confirm($('body').data('close-confirmation-message'))) return;

  if($(MODAL_CLASS).find('div.double-modal').length > 0)
    replace_modal_to_execute_test_run();
  else disappear_modal();
});

$(document).on('click', 'body', function (e){
  if ($(MODAL_CLASS).is(':hidden') || $(e.target).closest('.modal-dialog').length > 0 || $('.modal-dialog:visible').is(':hover')) return;
  $(MODAL_CLASS).find('.close').last().click();
});

function add_dropzone_validation_message(file, done) {
  var message = $('.dropzone > .dz-error-message');
  if (file.size > 2000000) {
    message.addClass('dz-error-message-active');
  }
  else {
    message.removeClass('dz-error-message-active');
    done();
  }
};
