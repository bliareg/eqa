const FILE_ITEM_VIEW = '<div class="preview_item">'+
                        '<span class="file-name" data-dz-name></span>' +
                        '<span class="icon-basket-icon remove" data-dz-remove></span>' +
                       '</div>';
const FILE_ITEM_PREVIEW = '<div class="dz-preview dz-file-preview preview_item">'+
                        '<div class="dz-progress"><span class="dz-upload" data-dz-uploadprogress></span></div>' +
                       '</div>'
const ISSUES_DROPZONE_PARAMS = {
  paramName1: 'issue[attachments_attributes[]]',
  paramName2: '[file]',
  maxFilesize: 100,
  parallelUploads: 10,
  uploadMultiple: true,
  clickable: '.upload_file',
  previewsContainer: '#preview .items',
  init: function() {
    myDropzone = this;
  }
};

function init_new_issue_dropzone() {
  if ($('#new_issue, .edit_issue, .issue_info').length) {

    if ($("#new_issue").length) {
      $("#new_issue").dropzone($.extend({
        autoProcessQueue: false,
        previewTemplate: FILE_ITEM_VIEW,
      }, ISSUES_DROPZONE_PARAMS));

      myDropzone.on("success", function(data) {
        if ($('.add_issue #new_issue').length) {
          var project_id = $('#new_issue').data('project-id');
          if (location.href.match(/test_run_result/)) {
            replace_modal_to_execute_test_run();
          } else {
            hide_modal();
          }
        } else {
          hide_modal();
          response = JSON.parse(data.xhr.response);
          $('body').append($(response.notification));
        }
      });
    } else {
      $(".edit_issue, .issue_info").dropzone($.extend({
        url: $('.edit_issue').attr('action'),
        method: 'PUT',
        autoProcessQueue: true,
        previewTemplate: FILE_ITEM_PREVIEW,
        success: function(data, response) {
          $('.preview_item').last().replaceWith(response.html_preview);
        }
      }, ISSUES_DROPZONE_PARAMS));
    }

    $(".btn-delete").click(function() {
      myDropzone.removeAllFiles(true);
    });
    dropzone_submit(myDropzone);
  }
  $(document).on('click', '.delete_attachment', function(e) {
    e.preventDefault();
    e.stopImmediatePropagation();
    var attachment_id = $(this).parents('.preview_item').data('attachment-id');
    var that = $(this);
    if (confirm('Are you sure you want to delete this?')) {
      $.ajax({
        type: 'DELETE',
        url: 'attachments/' + attachment_id,
        success: function(data) {
          that.parent().fadeOut(300);
        }
      });
    }
  });
}
