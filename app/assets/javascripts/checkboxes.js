var Checkboxes = {
  preventClickWhenCheckboxesNotChecked: {
    inactiveClass: 'inactive',
    init: function(button, checkboxes) {
      this.button = button;
      checkboxes.change(function() {
        if (checkboxes.filter(':checked').length) {
          Checkboxes.preventClickWhenCheckboxesNotChecked.enableButton();
        } else {
          Checkboxes.preventClickWhenCheckboxesNotChecked.disableButton();
        }
      });
    },
    disableButton: function() {
      this.button.addClass(this.inactiveClass);
      this.button.attr('disabled', 'disabled');
    },
    enableButton: function() {
      this.button.removeClass(this.inactiveClass);
      this.button.attr('disabled', null);
    }
  }
};
