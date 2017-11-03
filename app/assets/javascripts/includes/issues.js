$(document).ready(function() {
  $('#addNewColumn').on('click', newColumnDialog);
  $('.cancel').on('click', closeDialog);
});

function activeBtn() {
  var $self = $(this);
  var $parrent = $self.closest('.head_title_middle');

  $parrent.find('.active').removeClass('active');
  $self.addClass('active');
}

function activeColor(e) {
  var $target = $(e.target);
  var $parrent = $target.closest('.color_list');

  $parrent.find('.active').removeClass('active');
  $target.closest('li').addClass('active');
  validate_color_picker($parrent.parents('.color_picker'));
}

function newColumnDialog() {
  $('.new_border').fadeIn();
}

function closeDialog(e) {
  $(e.target).closest(MODAL_CLASS).fadeOut();
}

function initialize_scroll_bar() {
  bind_custom_scrollbar();
}

function init_issue_info() {
  init_spent_time_tab();
  init_description_field();

  $('.edit_issue_btn').click(function () {
    $('.issue-info-block.info_block, .view-btn-group').hide();

    $('.issue-info-block.edit-issue-block, .edit-btn-group').show();
    $('.edit-issue-block .edit-inner-wrap').append($('.row.issue-attachments'));
    $('.issue-info-tab .modal-content-scroll').addClass('edit-block');
    $('#user-select-data').appendTo('.row.assigned-to .col.xs-10');
  });

  $('.submit_editing').on('click', function () {
    $('.issue-info-block.info_block, .view-btn-group').show();
    $('.issue-info-block.edit-issue-block, .edit-btn-group').hide();
    $('.description-field').html(
      $('#issue_description').val().replace(/\</g, '&lt')
                             .replace(/\>/g,'&gt').replace(/(?:\n\r?|\r\n?)/g, '<br>')
    );
    $('.issue-title').text($('#issue_summary').val());
    $('.issue-info-block.info_block').append($('.row.issue-attachments'));
    $('.issue-info-tab .modal-content-scroll').removeClass('edit-block');
    $('#user-select-data').appendTo('.row.assigned-to .col.xs-4');
    init_description_field();
  });

  $('.show-all').on('click', function () {
    var $descField = $('.description-field');
    $descField.toggleClass('open-all');
    $(this).find('.show_all').toggle();
    $(this).find('.show_less').toggle();
  });
}

function init_description_field() {
  description_field = $('.description-field')
  // if field empty?
  if (description_field.html().match(/^\s*$/)) {
    description_field.parents('.description').addClass('empty');
  } else {
    description_field.parents('.description').removeClass('empty');
  }
}
