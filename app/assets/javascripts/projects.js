$(document).on('ready', function() {

  $(document).on('ajax:success', 'a.link_profile_menu', function(e, data) {
    if ($('*').is('#testingActivities')) {
      init_test_activities_diagrams();
      test_activity_js_actions();
      bind_custom_scrollbar();
    }
    custom_select();
  });

  $(document).on('ajax:success', 'a.plans-item-inner-left', function(e, data) {
    if ($('*').is('#testingActivities')) {
      test_activity_js_actions();
      bind_custom_scrollbar();
    }
  });

  $(document).on('click', '.nav-tabs :nth-child(2)', function(e){
    $('#testingActivities').hide();
  })

  crashes_init();
  integrations_init();
});

function projects_left_manu_action(browser_path) {
  window.history.pushState({}, '', browser_path);
  highlight_project_left_menu_item(browser_path);
}

function crashes_init() {
  $('.test-crash .chevron-down').click(function() {
    if ($(this).hasClass('chevron-up')) {
      $(this).addClass('chevron-down');
      $(this).removeClass('chevron-up');
      $(this).parents('tr').next().toggle()
    } else {
      $(this).addClass('chevron-up');
      $(this).removeClass('chevron-down');
      $(this).parents('tr').next().toggle()
    }
  });
}

function integrations_init() {
  $('.plugins-info-tab .plans-info-item').click (function() {
    $('.plugins-info-tab .plans-info-item').removeClass('active');
    $('.plugins-card').hide();

    $(this).addClass('active');
    $('.plugins-card[data-id=' + $(this).data('id') + ']').show();
  });
}

$(document).on('click', '.copy-token a', function(event) {
  selection = window.getSelection();
  range = document.createRange();
  range.selectNodeContents($(this).parent().siblings('span')[0]);
  selection.removeAllRanges();
  selection.addRange(range);
  document.execCommand('copy');
  $(this).fadeIn(200).text($(this).data('copied-text'));
  var copy_toke_link = $(this);
  setTimeout(function(){ copy_toke_link.text(copy_toke_link.data('copy-link-text')); }, 3000);
});

$(document).on('click', '.sdk-integration-tabs a', function (e) {
  e.preventDefault();
  var tab = $(this);
  var prev_tab = $('.sdk-integration-tabs a.active')
  prev_tab.removeClass('active');
  $(prev_tab.attr('href')).hide();

  tab.addClass('active');
  $(tab.attr('href')).show();
});

function build_link_inform_init() {
  $('.link_inform_copy_link').click(function(event) {
    selection = window.getSelection();
    range = document.createRange();
    range.selectNodeContents($(this).parent().siblings('a.link-to-object')[0]);
    selection.removeAllRanges();
    selection.addRange(range);
    document.execCommand('copy');
  });
}

function init_new_project_dropzone() {
  if ($('#new_project, .edit_project').length) {
    $("#new_project, .edit_project").dropzone({
      maxFiles: 1,
      acceptedFiles: 'image/*',
      paramName: 'project[logo_attributes[file]]',
      addRemoveLinks: false,
      autoProcessQueue: false,
      thumbnailWidth: 280,
      thumbnailHeight: 280,
      uploadMultiple: false,
      clickable: ['#new_project .card-image-load, .edit_project .card-image-load', '#reload'],
      previewsContainer: document.getElementById('preview-template'),
      init: function() {
        myDropzone = this;

        this.on("addedfile", function(file) {
          if (this.files.length > 1) {
            this.removeFile(this.files[0]);
          }
          $('#info_notice').html('');
          $('.card-image-load .dz-preview.dz-image-preview').hide();
        });

        myDropzone.on("error", function(file,response) {
          // if (file.size > myDropzone.options.maxFilesize * 1024 * 1024) {
          if (file.size/1024 > myDropzone.options.maxFilesize) {
            myDropzone.removeFile(file);
            $('#info_notice').html('You cant upload file more than ' +
                                   myDropzone.options.maxFilesize + ' Megabytes.');
          } else if (file.type.match(/image.*/)) {
            myDropzone.removeFile(file);
            myDropzone.addFile(file);
          } else if ($('.edit_project').length) {
            $('.dropzone-previews > .dz-preview').hide();
            $('#info_notice').html('You cant upload files of this type.');
          }
        });

        this.on("success", function() {
          hide_modal();

          if ($('#new_project').length) {
            window.location.href = '/projects';
          }
          if ($('.edit_project').length) {
            var project_id = $('.edit_project').data('project-id');
            $.ajax({
              type: 'GET',
              url: '/projects/' + project_id +'/settings',
              dataType : 'script',
              data: { "page": "settings" }
            });
          }
        });
      },
      accept: add_dropzone_validation_message
    });

    $('.btn-delete').on("click", function(e) {
      $('.dropzone-previews > .dz-error').hide();
      if (myDropzone.getQueuedFiles().length > 0) {
        myDropzone.removeAllFiles(true);
        $('.card-image-load .dz-preview.dz-image-preview').show();
      } else if ($('.edit_project').length) {
        if ($('#project_logo').length) {
          if (confirm('Are you sure you want to delete logo?')) {
            var project_id = $('.edit_project').data('project-id');
            $('#project_logo').remove();
            $.ajax({
              type: 'put',
              url: '/projects/' + project_id + '/remove_project_logo',
              success: function(data) {
                $('.btn.load-btn').show();
                $('.dz-preview').hide();
                $('#info_notice').html('Logo successfully deleted!');
              }
            });
          }
        }
      }
    });
    dropzone_submit(myDropzone);
  }
}

function highlight_project_left_menu_item(browser_path) {
  var selector = 'ul#left-menu > li > a';
  $(selector + '.active').removeClass('active');
  $(selector + "[href='" + browser_path + "']").addClass('active');
};
