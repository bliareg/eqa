$(document).on('load:page ready', function() {

  $(document).on('change', '#language', function() {
    window.location.href = window.location.origin + window.location.pathname + '?locale=' + $(this).val();
  });

});