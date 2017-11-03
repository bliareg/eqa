$(document).on('click', '#send_referral_emails', function(e) {
    var emails = $('.checkbox:checked').map(function(){
      return $(this).val();
    }).get();
    $.ajax({
      type: 'POST',
      data: { emails: emails },
      url: '/referrals/send_email',
      success: function () {
        disappear_modal();
      }
    });
});
