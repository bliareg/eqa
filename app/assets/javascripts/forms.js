$(document).on('change', '.modal form :input', function (){
  $(this).parents('form').data('changed', true);
});

$(document).on('ajax:success', '.modal form', function (){
  $(this).data('changed', false);
});