function init_send_link_to_email() {
  $('.send_link_to_email').click(function(e, data){
    var test_object_id = $(this).data('test-object-id');
    var checkboxes = $('#send_link tr.member td .checkbox:checked');
    var emails = [];
    checkboxes.each(function(){
      emails.push($(this).parent().siblings().children('.member-email').text());
    })
    if (emails.length) {
      $.ajax({
        type: 'POST',
        data: { emails: emails },
        url: '/test_objects/' + test_object_id + '/mailers',
        success: function(){
          hide_modal();
        }
      });
    }
  });

  $('#send_link tr.member td input:checkbox').change(function(){
    var members = $('#send_link tr.member');
    var title_checkbox = $('#send_link tr.table-title input:checkbox');

    if (members.length == members.find('td .checkbox:checked').length ) {
      title_checkbox.prop('checked', true);
    } else {
      title_checkbox.prop('checked', false);
    }
  });

  $('#send_link tr.table-title input:checkbox').click(function(){
    var is_checked = $(this).prop('checked');
    $('#send_link tr.member td input:checkbox').prop('checked', is_checked).change();
  });
}

function update_test_objects_content(project_id) {
  //console.log('function update_test_objects_content()')
  $.ajax({
    type: 'GET',
    dataType: 'script',
    url: '/projects/' + project_id + '/test_objects',
    success: function() {
      show_modal();
    }
  });
}
function init_test_object_dropzone() {
  if ($('#new_upload').length) {
    var mediaDropzone = new Dropzone("#new_upload", {
      maxFilesize: 1024,
      paramName: 'test_object[file]',
      maxFiles: 1,
      uploadMultiple: false,
      clickable: true,
      dictDefaultMessage: '<span class="default-message">Drop your <span>IPA</span>' +
                          ' or <span>APK</span> here or click to select file</span>' +
                          '<span class="default-message"><p>Maximum file size allowed is 1 Gb</p></span></div>',
      acceptedFiles: ".ipa, .apk"
    });
    mediaDropzone.on("addedfile", function(file) {
      if (mediaDropzone.files.length > 1) {
        mediaDropzone.removeFile(mediaDropzone.files[0]);
      }
      var ext = file.name.substr(file.name.lastIndexOf('.'));
      if (ext && ext.match(/\.ipa|\.apk/)) {
        before_upload_test_object_action()
      }
    });
    mediaDropzone.on("error", function(file,response) {
      $(".dz-default.dz-message").show()
    });
    mediaDropzone.on("complete", function(file) {
      var response = JSON.parse(file.xhr.response);
      after_upload_test_object_action(response);
      build_link_inform_init();
    });

    mediaDropzone.on("uploadprogress", function(file, progress) {
      $("#progressbar").progressbar({ value: progress - 5 });
    });
  }
}

function before_upload_test_object_action() {
  $('.dz-message').prop("disabled", true);
  $('#new_upload, .load-cloud-description, .upload-build .title').hide();
  $('#link_upload').hide();
  $('div.title-main > span.close').hide();
  $("#progressbar").progressbar({ value: 0 });;
}

function after_upload_test_object_action(response) {
  $('#after_upload').append($(response.after_upload_html));
  $('#after_upload').show();
  $('div.title-main > span.close').show();
  response_path = window.location.href.match(/\/\w+(?=\?)|\/\w+$/)[0]
  if (old_browser_path == '/projects' || old_browser_path.match(/organizations/)) {
    $('.project_counters[data-project-id=' + response.project_id + ']').html(response.html);
  } else if (response_path == '/test_objects') {
    $('.main-content').html(response.html);
  } else {
    $('.main-content').html(response.html);
    init_project_overview_diagram();
  };

  $("#progressbar").progressbar({ value: 100 });
  $('.modal-content #after_upload > .file-info').fadeIn(1200);
}

$(document).on('click', '.test-object .chevron span', function() {
  if ($(this).hasClass('chevron-up')) {
    $(this).addClass('chevron-down');
    $(this).removeClass('chevron-up');
    $(this).parents('tr').next().children().children().toggle()
  } else {
    $(this).addClass('chevron-up');
    $(this).removeClass('chevron-down');
    $(this).parents('tr').next().children().children().toggle()
  }
});
