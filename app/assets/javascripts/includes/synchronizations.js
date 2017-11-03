function init_select_sync_plugin() {
  if ($('.synchronize_plugin').length) {
    $('.synchronize_plugin').click(function() {
      var plugin_settings = [];
      $('.plugin_settings td .checkbox:checked, .plugin_settings td .radio:checked').parent('td').each(function () {
        var name = $(this).attr('plugin-name');
        var id = $(this).attr('plugin-id');
        plugin_settings.push({ name: name, id: id });
      });

      $.ajax({
        url: $(this).attr('path'),
        type: 'POST',
        data: { plugin_settings: plugin_settings }
      });
    });

    collection_check_box_init('.synchronization');
  }
}

function collection_check_box_init(uniq_class) {
  $(uniq_class + ' tr.table-field td input:checkbox').change(function(){
    var body_checkboxes = $(uniq_class + ' tr.table-field');
    var title_checkbox = $(uniq_class + ' tr.table-title input:checkbox');

    if (body_checkboxes.length == body_checkboxes.find('td .checkbox:checked').length ) {
      title_checkbox.prop('checked', true);
    } else {
      title_checkbox.prop('checked', false);
    }
  });

  $(uniq_class + ' tr.table-title input:checkbox').click(function(){
    var is_checked = $(this).prop('checked');
    $(uniq_class + ' tr.table-field td input:checkbox').prop('checked', is_checked).change();
  });
}