/*global $*/

$(document).ready(function() {
    'use strict';

    var _debounce = function(func, wait, immediate) {
        var timeout;

        return function() {
            var self = this;
            var args = arguments;
            var later = function() {
                timeout = null;
                !immediate && func.apply(self, args);
            };
            var callNow = immediate && !timeout;

            clearTimeout(timeout);
            timeout = setTimeout(later, wait);

            callNow && func.apply(self, args);
        };
    };

    var clearFakeInputs = _debounce(function() {
        $('.fake-input').val('');
    }, 2000);

    function detectActiveRowIn($container) {
        var $result = $container.find('.key-press-point');
        $result.length || ($result = $container.find('.dd-option-selected').parent());

        return $result;
    }

    function detectSearchedValue(criteria, $container) {
        var $searchList = $container.find('.dd-option-text');
        var len = $searchList.length;
        var i = 0;
        var candidate;

        if (!len) { return false; }

        while (i < len) {
            candidate = $($searchList[i]);

            if (candidate.text().toLowerCase().indexOf(criteria) === 0) {
                return candidate.closest('li');
            }

            i += 1;
        }

        return false;
    }

    $(document).on('keydown', function(ev){
        ev.which === 9 && $.data(document.body, '__$_tab', true);
    });

    $(document).on('keyup', function(ev){
        ev.which === 9 && $.data(document.body, '__$_tab', false);
    });

    $(document).on('focus', '.fake-input', function(ev, opts) {
        if (!$.data(document.body, '__$_tab')) { return; }

        var expectedId = $(this).data('next');
        var $expectedDDslick = $('#' + expectedId);

        $expectedDDslick.ddslick('open');
    });

    $(document).on('click', '.dd-option', function(ev) {
        $(ev.target).closest('.dd-options').find('.key-press-point').removeClass('key-press-point');
    });

    $(document).on('input', '.fake-input', _debounce(function(ev) {
        var $target = $(ev.target);
        var criteria = $target.val().trim().toLowerCase();
        var $resultRow;
        var $activeOpt;

        clearFakeInputs();

        if (!criteria) { return; }

        var expectedId = $target.data('next');
        var $expectedDDslick = $('#' + expectedId);
        var $optsContainer = $expectedDDslick.find('.dd-options');

        $resultRow = detectSearchedValue(criteria, $optsContainer);

        if ($resultRow){
            $activeOpt = detectActiveRowIn($optsContainer);
            $activeOpt.removeClass('key-press-point');
            $resultRow.addClass('key-press-point');

            $optsContainer.mCustomScrollbar('scrollTo', $resultRow, {
                scrollInertia: 0
            });
        }
    }, 500));

    $(document).on('keydown', '.fake-input', function(ev) {
        var expectedId = $(this).data('next');
        var $expectedDDslick = $('#' + expectedId);
        var $optsContainer;
        var $activeOpt;
        var $optsList;
        var $optIndex;
        var $resIndex;
        var $resEl;
        var isOpen;

        function verticalMove(boolVal) { //up: true, down: false
            $activeOpt = detectActiveRowIn($optsContainer);
            $optsList = $optsContainer.find('li');

            if (!$optsList.length) { return; }

            $optIndex = $optsList.index($activeOpt);
            $resIndex = boolVal ? (($optIndex - 1 >= 0) ? ($optIndex - 1) : $optIndex) : (($optIndex + 1 < $optsList.length) ? ($optIndex + 1) : $optIndex);
            $activeOpt.removeClass('key-press-point');
            $resEl = $optsList.eq($resIndex);
            $resEl.addClass('key-press-point');

            $optsContainer.mCustomScrollbar('scrollTo', $resEl, {
                scrollInertia: 100
            });
        }

        isOpen = $expectedDDslick.find('.dd-select').hasClass('dd-open');
        $optsContainer = $expectedDDslick.find('.dd-options');

        switch (ev.which) {
            case 13: //select
                ev.preventDefault();

                if (isOpen) {
                    $activeOpt = detectActiveRowIn($optsContainer);
                    $optsList = $optsContainer.find('li');

                    if (!$optsList.length) { return; }

                    $optIndex = $optsList.index($activeOpt);
                    $activeOpt.removeClass('.key-press-point');
                    $expectedDDslick.ddslick('select', {index: $optIndex});
                } else {
                    $expectedDDslick.ddslick('open');
                }
                return;
            case 38: //up
                isOpen && verticalMove(true);
                return;
            case 40: //down
                isOpen && verticalMove(false);
                return;
            case 9: //tab
            case 27: //esc
                isOpen && $expectedDDslick.ddslick('close');
                return;
        }
    })
});


function generate_fake_input() {
    $('select').each(function(){
        if ($(this).prev('.fake-input').length == 0) {
            $(this).before('<input type="text" class="fake-input" data-next="' + $(this).attr('id') + '" />');
        }
    })
}