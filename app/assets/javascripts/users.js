var User = {
  password: {
    current_password_validation: function() {
      if ($('#edit_user_password').length) {
        client_side_validation_params = $('#edit_user_password')[0].ClientSideValidations.settings.validators
        client_side_validation_params['current_password'] = client_side_validation_params['user[password]']
      }
    }
  }
}

$(document).ready(function() {
  notifications_init();
  all_notifications_title();
})

$(document).on('page:load ready', function() {

  $(document).on('ajax:success', '#content form.edit_user', function(e, data) {
    if(data.status == 'success') {
      $('#content #personal_info_notice').addClass('success');
      $('#content #personal_info_notice').html('<p>' + data.message + '</p>');
    } else if (data.status == 'success_change_password') {
      window.location.reload();
    } else {
      if (data.field_id) {
        $field = $('#' + data.field_id)
        $field.parents('form')[0].ClientSideValidations.addError($field, data.message);
      } else {
        $('#content #personal_info_notice').addClass('error');
        $('#content #personal_info_notice').html('');
        if (typeof data.message == 'string') {
          $('#content #personal_info_notice').append('<p>' + data.message + '</p>');
        } else {
          $.each(data.message, function(key, value) {
            $('#content #personal_info_notice').append('<p>' + key + ': ' + value.join(', ') + '</p>');
          });
        }
      }
    }
  });
});

function test_run_notification_init() {
  $('.test-run-notification').click(function() {
    switch_element = $(this)
    data = {
      action: switch_element[0].checked,
      notificable_ids: [switch_element.data('test-run-id')],
      notificable_type: 'TestRun'
    }
    $.ajax( {
      type: 'PUT',
      data: {notifications: data},
      url: '/toggle_notifications',
    });
  })
}

function notifications_init() {
  $(".project_notification").click(function(){
    switch_element = $(this)
    data = {
      action: switch_element[0].checked,
      notificable_ids: [switch_element.val()],
      notificable_type: 'Project'
    }

    if((org_element = $(this).closest('.notification-team')).length > 0) {
      each_notification_title(org_element);
      init_disable_notifications();
    }
    $.ajax({
      type: 'PUT',
      data: {notifications: data},
      url: '/toggle_notifications',
    });
  });

  $(".disable_email").click(function() {
    ids = [];
    $(".project_notification").each(function(i, val){
      if (val.checked == true) {
        ids.push(val.value);
        val.checked = false;
      }
    })
    $('.card-tab-content').last().hide(600);
    all_notifications_title();
    data = {
      action: false,
      notificable_ids: ids,
      notificable_type: 'Project'
    }
    $.ajax({
      type: 'PUT',
      data: {notifications: data},
      url: '/toggle_notifications'
    });
  });

  $(".enable_all").click(function(){
    ids = [];
    $(this).closest('.notification-team').find('.project .project_notification')
                                         .each(function(i, val){
      if (val.checked == false) {
        ids.push(val.value);
        val.checked = true;
      }
    })
    $(this).hide();
    $(this).siblings('.disable_all').show();
    init_disable_notifications();
    data = {
      action: true,
      notificable_ids: ids,
      notificable_type: 'Project'
    }
    $.ajax({
      type: 'PUT',
      data: {notifications: data},
      url: '/toggle_notifications'
    });
  });

  $(".disable_all").click(function(){
    ids = [];
    $(this).closest('.notification-team').find('.project .project_notification')
                                         .each(function(i, val){
      if (val.checked == true) {
        ids.push(val.value);
        val.checked = false;
      }
    })
    data = {
      action: false,
      notificable_ids: ids,
      notificable_type: 'Project'
    }
    $(this).hide();
    $(this).siblings('.enable_all').show();
    init_disable_notifications();
    $.ajax({
      type: 'PUT',
      data: {notifications: data},
      url: '/toggle_notifications'
    });
  });
}

function all_notifications_title() {
  var array = $('.notification-team')
  for (var i = 0; i < array.length-1; i++) {
    var count = $(array[i]).find('input:checked').length
    if (count == 0) {
      $(array[i]).find(".disable_all").hide()
      $(array[i]).find(".enable_all").show();
    } else if (count == $(array[i]).find('.switch-checkbox').length) {
      $(array[i]).find(".enable_all").hide();
      $(array[i]).find(".disable_all").show();
    }
  }
}

function each_notification_title(element) {
  var count = element.find('input:checked').length
  if (count == 0) {
    element.find(".disable_all").hide()
    element.find(".enable_all").show()
  } else if (count == element.find('.switch-checkbox').length) {
    element.find(".enable_all").hide()
    element.find(".disable_all").show()
  } else {
    element.find(".enable_all").show()
    element.find(".disable_all").show()
  }
}

function init_disable_notifications() {
  var all_count = $('.project_notification').length
  var disabled_count = $('input:checkbox:not(:checked)').length
  if (all_count == disabled_count) {
    $('.disable_email').closest('.card-tab-content').hide(600)
  } else {
    $('.disable_email').closest('.card-tab-content').removeClass('hide').show(600)
  }
}

$(document).on('click', '.dropzone .dz-error-mark:visible', function() {
  $('.avatar').attr('src','/images/users.png');
  $('.dz-preview ').hide();
  $('.btn.load-btn').show();
});

$(document).on('ajax:success', '#destroy_avatar', function(e, data) {
  $('.avatar').attr('src','/images/users.png');
  $('.dz-preview ').hide();
  $('.btn.load-btn').show();
  $('.load_avatar_instruction').show();
  $('#destroy_avatar').css('pointer-events', 'none');
});

function init_upload_avatar_dropzone() {
  if ($('#upload_avatar').length) {
    $("#upload_avatar").dropzone({
      maxFilesize: 2,
      acceptedFiles: 'image/*',
      paramName: 'user[avatar_attributes[file]]',
      addRemoveLinks: false,
      thumbnailWidth: 240,
      thumbnailHeight: 190,
      clickable: ['#upload_avatar > .card-image-load',
                  '#upload_avatar > div.card-image-btns > a.btn-reload'],
      init: function() {
        myDropzone = this;
        myDropzone.on("error", function(file) {
          $('.dropzone .dz-preview .dz-error-message').css('opacity','1');
        });
        myDropzone.on("addedfile", function(file) {
          if (this.files.length > 1) {
            this.removeFile(this.files[0]);
          }
          $('#destroy_avatar').css('pointer-events', '');
          $('.card-image-load .dz-preview.dz-image-preview').hide();
          $('.load_avatar_instruction').hide();
        });
      }
    });
  }
}

function initialize_country_select() {
  $('#countryMyProfile .dd-option, #country .dd-option').each(function(){
    $(this).attr('title', $(this).children('.dd-option-text').text());
  })
}