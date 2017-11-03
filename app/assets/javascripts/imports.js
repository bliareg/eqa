var Import = {
  csv_file: null,
  map_fields: {
    init: function() {
      bind_custom_scrollbar();
      this.select.init();
      this.back_button.init();
      this.select.validate();
    },
    select: {
      selector: '.import_select',
      start_import_btn: null,
      init: function() {
        items = $(this.selector);
        this.start_import_btn = $('#start-import');
        items.chosen();
        items.on('change', this.validate);
        items.next('.chosen-container').on('click', this.checkOpenSide);
      },
      validate: function() {
        if (Import.map_fields.select.is_valid()) {
          Import.map_fields.select.start_import_btn.addClass('btn-green');
          Import.map_fields.select.start_import_btn.unbind('click', Import.map_fields.submit)
                                           .one('click', Import.map_fields.submit);
        } else {
          Import.map_fields.select.start_import_btn.removeClass('btn-green');
          Import.map_fields.select.start_import_btn.unbind('click', Import.map_fields.submit);
        }
      },
      is_valid: function() {
        var is_valid = true
        $(this.selector + '[required]').each(function() {
          if (!$(this).val()) {
            is_valid = false;
            return false;
          }
        });
        return is_valid;
      },
      checkOpenSide: function() {
        var modalContainer = $('.modal .map-fields .modal-content .modal-content-scroll'),
            modalContainerOffsetHeight = modalContainer.offset().top + modalContainer.height(),
            dropdown = $(this).find('.chosen-drop'),
            dropdownOffsetHeight = dropdown.offset().top + dropdown.height();
        if (dropdownOffsetHeight > modalContainerOffsetHeight) {
          $(this).addClass('up');
        } else {
          $(this).removeClass('up');
        }
      }
    },
    back_button: {
      init: function() {
        $('.back_import_button').click(function(){
          $('.modal .import-case').show();
          $('.modal .map-fields').remove();
          myDropzone.addFile(Import.csv_file);
        });
      }
    },
    submit: function() {
      $('.modal-body').find('form').submit();
    },
  },
  upload_file: {
    init: function() {
      this.dropzone.init();
      this.next_btn.init();
    },
    error_notice_selector: '#error_notice',
    dropzone: {
      init: function () {
        $("#upload_csv_file").dropzone({
          paramName: '[file]',
          autoProcessQueue: false,
          clickable: '.dropzone',
          previewsContainer: '#loadPreview',
          acceptedFiles: ".csv",
          previewTemplate: FILE_ITEM_VIEW,
          success: this.success,
          init: this.initialize
        });
      },
      success: function(file, data) {
        $('.modal .import-case').hide();
        $(MODAL_CLASS).append(data.html);
      },
      initialize: function() {
        myDropzone = this;
        myDropzone.on("addedfile", Import.upload_file.dropzone.on_added_file);
        myDropzone.on("removedfile", Import.upload_file.dropzone.on_removed_file);
        myDropzone.on("error", Import.upload_file.dropzone.on_error);
        myDropzone.on("complete", Import.upload_file.dropzone.on_complete);
      },
      on_added_file: function(file) {
        if (this.files.length > 1) {
          this.removeFile(this.files[0]);
        }
        Import.csv_file = file;
        $(Import.upload_file.error_notice_selector).html('');
        $(Import.upload_file.next_btn.selector).toggleClass('btn-green btn-grey');
      },
      on_removed_file: function(file) {
        $(Import.upload_file.next_btn.selector).toggleClass('btn-green btn-grey');
      },
      on_error: function(file, data) {
        myDropzone.removeAllFiles(true);
        $('.dropzone-previews > .dz-preview').hide();
        $(Import.upload_file.error_notice_selector).html(data.message || 'You cant upload files of this type.');
      },
      on_complete: function(file, data) {
        myDropzone.removeAllFiles();
      }
    },
    next_btn: {
      selector: '#next',
      init: function() {
        $(this.selector).click(function() {
          var select = $('#test_plan_id_csv');
          var selected = select.find('.dd-selected-value');
          if (selected.val() == "") {
            if (!select.parent().is(".field_with_errors")) {
              error_text = $('div.modal-body').data('error')
              select.after("<label class='message'>" + error_text + "</label>")
                    .siblings()
                    .andSelf()
                    .wrapAll( "<div class='field_with_errors' />");
            }
          } else if (select.parent().is(".field_with_errors")){
            $('.field_with_errors .message').remove();
            select.unwrap();
          } else if (myDropzone.getQueuedFiles().length > 0){
            myDropzone.processQueue();
          }
        });
      }
    }
  }
}

