function init_payments_page() {
  // initialize_payment_method_form();
  licenses_changer_event();
  init_paypal_buttons();
};

function init_paypal_buttons(){
  if ( $('body').hasClass('locale-en')) {
    locale_for_buttons = 'en_US';
  } else {
    locale_for_buttons = 'ru_RU';
  }
  if ($('div#paypal-button-container-regular').length > 0){
    init_regular_paypal_button();
  }
  if ($('div#paypal-button-container-add').length > 0){
    init_add_paypal_button();
  }
}

function init_add_paypal_button(){
  paypal.Button.render({
    env: 'production', // sandbox | production
    style: {
      label: 'pay', // checkout | credit | pay
      size:  'small',
      shape: 'rect',     // pill | rect
      color: 'blue'      // gold | blue | silver
    },
    locale: locale_for_buttons,
    commit: true,
    payment: function() {
      var CREATE_URL = '/paypal_payments';
      var data = {
        licenses_amount: $('#paypal-button-container-add').data('licenses-amount'),
        promocode: $('#promocode_add').val(),
        number_of_months: $('#number_of_months').val()
      }
      return paypal.request.post(CREATE_URL, data)
        .then(function(res) {
          if (res.full_discount) {
            window.location.href = '/payments'
          } else {
            return res.paymentID;
          }
        });
    },
    onAuthorize: function(data, actions) {
      return paypal.request.post(data.returnUrl)
        .then(function (res) {
          window.location.href = '/payments'
        });
    },
    onCancel: function(data, actions) {
      $.ajax({
        type: 'DELETE',
        url: data.cancelUrl
      });
    }
  }, '#paypal-button-container-add');
}

function init_regular_paypal_button(){
  paypal.Button.render({
    env: 'production', // sandbox | production
    style: {
      label: 'pay', // checkout | credit | pay
      size:  'small',
      shape: 'rect',     // pill | rect
      color: 'blue'      // gold | blue | silver
    },
    locale: locale_for_buttons,
    commit: true,
    payment: function() {
      var CREATE_URL = '/paypal_payments';
      var data = {
        promocode: $('#promocode_regular').val(),
        number_of_months: $('#number_of_months_regular').val()
      }
      return paypal.request.post(CREATE_URL, data)
        .then(function(res) {
          if (res.full_discount) {
            window.location.href = '/payments'
          } else {
            return res.paymentID;
          }
        });
    },
    onAuthorize: function(data, actions) {
      return paypal.request.post(data.returnUrl)
        .then(function (res) {
          window.location.href = '/payments'
        });
    },
    onCancel: function(data, actions) {
      $.ajax({
        type: 'DELETE',
        url: data.cancelUrl
      });
    }
  }, '#paypal-button-container-regular');
}

$(document).on('click', '.close_notification', function(e) {
  $.ajax({
    type: 'PUT',
    url: '/users/toggle_payment_notification',
    success: function() {
      $('.with-top-panel').removeClass('with-top-panel');
      $('.notification-top-panel').remove();
    }
  });
});

$(document).on('click', '#autopayments', function(e) {
  $.ajax({
    type: 'PUT',
    url: '/billings/toggle_autopayment'
  });
});

$(document).on('click', 'input[name=payment_method]', function(e) {
  payment_method_id = $(this).val();
  url = '/payment_methods/' + payment_method_id + '/make_default'
  $.ajax({
    type: 'PUT',
    url: url,
    success: function() {
      $('.load-block').hide();
    }
  });
});

$(document).on('click', '#regular_payment', function(e) {
  $.ajax({
    type: 'POST',
    url: '/payments'
  });
});

$(document).on('click', '#add_licenses', function(e) {
  data = {}
  data.licenses_amount = $(this).data('licenses-amount')
  $.ajax({
    type: 'POST',
    data: data,
    url: '/payments'
  });
});

$(document).on('click', '#reduce_licenses', function(e) {
  data = {}
  data.licenses_amount = $(this).data('licenses-amount')
  $.ajax({
    type: 'PUT',
    data: data,
    url: '/billings/update_licenses_amount'
  });
});

function initialize_payment_method_form() {
  if (typeof gon !== 'undefined') {
    braintree.setup(gon.client_token, "custom", {
      id: "checkout",
      paypal: {
        container: "paypal-button"
      },
      hostedFields: {
        number: {
          selector: "#card-number",
          placeholder: '**** **** **** ****'
        },
        expirationDate: {
          selector: "#expiration-date",
          placeholder: 'MM/YY'
        },
        cvv: {
          selector: "#cvv",
          placeholder: '***'
        }
      },
      onError: function(error){
        $('.load-block').hide();
        $('#add_payment_method').removeAttr('data-disable-with');
        $('#add_payment_method').removeAttr('disabled');
      }

    });
  }
}

$(document).on('click', '.show-payment-method-form', function() {
  $(this).hide()
  $(this).siblings('.show-payment-method-form').show()
  $('.add-method-block').toggle('slow');
});

function licenses_changer_event() {
  input_quantity = $('#quantity');
  input_number_of_months = $('#number_of_months')
  activating = input_quantity.data('activating')
  current_licenses_amount = parseInt(input_quantity.data('licenses-amount'))
  min_licenses_amount = parseInt(input_quantity.data('min-licenses-amount'))
  price = $('td.price').data('license-price');
  new_fee = $('.licenses-bottom-block > div > span.total-price');
  new_monthly_fee_span = $('#new_monthly_fee');
}

$(document).on('change', '#quantity', function(e) {
  change_info();
});

$(document).on('keyup', '#quantity', function(e){
  change_info();
});

$(document).on('change', '#number_of_months', function(e) {
  change_info();
});

$(document).on('keyup', '#number_of_months', function(e){
  change_info();
})

$(document).on('change', '#number_of_months_regular', function(e) {
  change_regular_info();
});

$(document).on('keyup', '#number_of_months_regular', function(e){
  change_regular_info();
})

function change_info(){
  var new_licenses_amount = input_quantity.val();
  var number_of_months = input_number_of_months.val();


  $('#licenses_amount').text(new_licenses_amount);
  $('#reduce_licenses').data('licenses-amount', new_licenses_amount)

  $('#new_licenses_amount').text(new_licenses_amount);
  $('#add_licenses').data('licenses-amount', new_licenses_amount)
  $('#paypal-button-container-add').data('licenses-amount', new_licenses_amount)

  new_value = Math.round(new_licenses_amount * price / 100).toFixed(2);
  if (activating){
    new_monthly_fee_span.text('$' + new_value);
    value_multi_months = (new_value * number_of_months).toFixed(2)
    new_fee.text('$' + value_multi_months);
    if (number_of_months == '' || new_licenses_amount == '' || new_licenses_amount < min_licenses_amount) {
      $('#increase_block').hide();
      $('#decrease_block').hide();
    } else if (new_licenses_amount < current_licenses_amount){
      $('#increase_block').hide();
      $('#decrease_block').show();
    } else {
      $('#decrease_block').hide();
      $('#increase_block').show();
    }
  } else {
    new_fee.text('$' + new_value);
    if (new_licenses_amount > current_licenses_amount) {
      added_licenses_count = new_licenses_amount - current_licenses_amount
      fee_per_new_license = input_quantity.data('fee-per-new-license')
      fee_per_new_licenses = (added_licenses_count * fee_per_new_license / 100).toFixed(2);
      $('#add_licenses').data('licenses-amount', added_licenses_count)
      $('#paypal-button-container-add').data('licenses-amount', added_licenses_count)
      $('#new_licenses_amount').text(added_licenses_count);
      new_fee.text('$' + fee_per_new_licenses);
      $('#increase_block').show();
      $('#decrease_block').hide();
    } else if (new_licenses_amount < current_licenses_amount && new_licenses_amount >= min_licenses_amount) {
      $('#increase_block').hide();
      $('#decrease_block').show();
    } else {
      $('#increase_block').hide();
      $('#decrease_block').hide();
    }
  }
}

function change_regular_info() {
  var licenses_amount = parseInt($('#number_of_months_regular').data('licenses-amount'));
  var number_of_months = $('#number_of_months_regular').val();
  var new_regular_price = (licenses_amount * price * number_of_months / 100).toFixed(2);
  $('#regular_monthly_fee').text('$' + new_regular_price);
  $('#price_with_promocode_regular').text('$' + new_regular_price);
}

$(document).on('click', '.show_loader', function() {
  $('.load-block').show();
})

$(document).on('click', '#check_promocode_add', function() {
  var data = {};
  data.licenses_amount = $('#new_licenses_amount').text();
  data.promocode = $('#promocode_add').val();
  data.regular_block = false;
  if (input_number_of_months.length) {
    data.number_of_months = input_number_of_months.val();
  }
  check_promocode(data);
})

$(document).on('click', '#check_promocode_regular', function() {
  var data = {};
  data.promocode = $('#promocode_regular').val();
  data.regular_block = true;
  data.number_of_months = $('#number_of_months_regular').val();
  check_promocode(data);
})

function check_promocode(data){
  $.ajax({
    type: 'POST',
    data: data,
    url: '/promocodes/check'
  });
}
