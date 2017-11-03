/**
 * Created by User on 19.08.2016.
 */

$(document).ready(function () {
    var $caretDown = $('.custom-select .fa-caret-down');
    var $customSelectList = $('.custom-select-list');
    var $customSelect = $('.custom-select');

    $caretDown.click(function () {

        if ($customSelect.hasClass('custom-select-open')) {

            $customSelect.removeClass('custom-select-open');
            $customSelectList.css({'display': 'none'});
        } else {
            $customSelect.addClass('custom-select-open');
            $customSelectList.css({'display': 'block'});
        }

    });
    
});

