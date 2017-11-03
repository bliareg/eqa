$(document).ready(function(){
  init_organization_members();
  init_change_roles()
})

$(document).on('turbolinks:load', function() {
  init_change_roles();
});

function init_organization_members() {
  $('.member .chevron-down').click(function() {
    click_member_list($(this))
  });
}

function click_member_list(element) {
  if (element.hasClass('chevron-up')) {
      element.addClass('chevron-down');
      element.removeClass('chevron-up');
      element.parents('tr').next().children().children().toggle()
    } else {
      element.addClass('chevron-up');
      element.removeClass('chevron-down');
      element.parents('tr').next().children().children().toggle()
    }
}

function init_current_member(element){
  $(element).click(function() {
    click_member_list($(this))
  });
}

function init_new_organization_dropzone() {
  if ($('#new_organization, .edit_organization').length) {
    $("#new_organization, .edit_organization").dropzone({
      paramName: 'organization[logo_attributes[file]]',
      maxFiles: 1,
      acceptedFiles: "image/*",
      addRemoveLinks: false,
      autoProcessQueue: false,
      thumbnailWidth: 280,
      thumbnailHeight: 280,
      uploadMultiple: false,
      clickable: ['#new_organization .card-image-load, .edit_organization .card-image-load', '#reload'],
      previewsContainer: document.getElementById('preview-template'),
      init: function() {
        myDropzone = this;

        myDropzone.on("addedfile", function(file) {
          if (this.files.length > 1) {
            this.removeFile(this.files[0]);
          }
          $('.card-image-load .dz-preview.dz-image-preview').hide();
        });

        myDropzone.on("error", function(file,response) {
          if (file.type.match(/image.*/)) {
            myDropzone.removeFile(file);
            myDropzone.addFile(file);
            $('#new_organization, .edit_organization ').submit();
          }
          if ($('.edit_organization').length) {
            $('.dropzone-previews > .dz-preview').hide();
            $('#info_notice').html('You cant upload files of this type.');
          }
        });
          myDropzone.on("success", function() {
          hide_modal();
          if ($('#new_organization').length) {
            window.location.href = '/organizations';
          } else {
            var organization_id = $('.edit_organization').data('organization-id');
            window.location.href = '/organizations/' + organization_id;
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
      } else if ($('.edit_organization').length) {
        if ($('#organization_logo').length) {
          if (confirm('Are you sure you want to delete logo?')) {
            var organization_id = $('.edit_organization').data('organization-id');
            $('#organization_logo').remove();
            $.ajax({
              type: 'put',
              url: '/organizations/' + organization_id + '/remove_organization_logo',
              success: function(data) {
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
