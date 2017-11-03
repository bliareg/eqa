function test_activity_js_actions(browser_path) {
  window.history.pushState({}, '', browser_path);

  $('.testing_activities .nav-tabs a').on('click', function (e){
    if ($(this).attr('disabled')) {
      e.preventDefault();
      e.stopImmediatePropagation();
    } else {
      $('.testing_activities .nav-tabs a').attr('disabled', true);
      $('.testing_activities .nav-tabs a').css('cursor', 'default');
      $.ajax({
        url: $(this).attr('href'),
        dataType: 'script',
        success: function() { set_disabled_test_activities_nav_tabs }
      });
    }
  });

  custom_select();
  init_nav_tabs();
  init_plan_togle_switcher();

  $(".modal-content .close").click(function () {
    $(MODAL_CLASS).removeClass("in");
    hide_modal();
  });

  $(".modal-body .cancel").click(function () {
    $(MODAL_CLASS).removeClass("in");
    hide_modal();
  });

  bind_custom_scrollbar();
  sortable_case_init();
  set_disabled_test_activities_nav_tabs();
}

function set_disabled_test_activities_nav_tabs() {
  $('.testing_activities .nav-tabs a').attr('disabled', false);
  $('.testing_activities .nav-tabs a').css('cursor', 'pointer');
  $('.testing_activities .nav-tabs a.active').attr('disabled', true);
  $('.testing_activities .nav-tabs a.active').css('cursor', 'default');
}

$(document).on('click', '.nav-tabs a', function (e) {
  var tab = $(this),
      prev_tab = $('.nav-tabs a.active');
  prev_tab.removeClass('active');
  $(this).addClass('active');
  $(tab).fadeIn(300);
});

function init_nav_tabs() {
  $('.nav-tabs a').click(function (e) {
    e.preventDefault();
    var tab = $(this);
    var prev_tab = $('.nav-tabs a.active')
    prev_tab.removeClass('active');
    $(this).addClass('active');
    if ($('.card-sdk-integrations').length) {
      $(prev_tab.attr('href')).hide();
      $(tab.attr('href')).show();
    }
    $(tab).fadeIn(300);
  });
}


function add_active_to_test_plan_tab() {
  $("a.highlight_link[href='" + window.location.pathname + "']").addClass('active');
  if ($('.testing_activities a.highlight_link.active').length) {
    $('.project_test_activities').addClass('active');
  } else if (window.location.pathname.match(/test_runs/)) {
    $('.project_test_activities').addClass('active');
    $('.test_runs_nav_link').addClass('active');
  } else if (window.location.pathname.match(/settings/)) {
    $('.project_settings').addClass('active');
  } else if (window.location.pathname.match(/synchronizations/)) {
    $('.project_integrations').addClass('active');
  }
};

function init_plan_togle_switcher() {
  var $plansOpen = $('.tab-pane-content .plans');
  var $containsClose = $('.tab-pane-content .contains');
  // var $newtestplanlinkClose =$('.tab-pane-content .newtestplanlink');
  var $btnBlock = $('.plans .open-addTestPlan');
  var $plansItemInnerLeft = $('.plans-item-inner-left');
  var $plansTab = $('.main-content-info a.link_profile_menu');
  var $plansToggle = $('.plans-toggle');
  var $caretIcon = $('.plans-toggle span');

  if (toggle_condition($plansTab)) {
    expand_plan_items($plansOpen,          $containsClose, $btnBlock,
                      $plansItemInnerLeft, $plansTab,      $caretIcon,
                      $plansToggle);
  } else {
    narrow_plan_items($plansOpen,          $containsClose, $btnBlock,
                      $plansItemInnerLeft, $plansTab,      $caretIcon,
                      $plansToggle);
  };
}

function toggle_condition($plansTab) {
  return $plansTab.hasClass('expanded');
};

$(document).on('click', '.plans-toggle', function() {
  $('.main-content-info a.link_profile_menu').toggleClass('expanded');
  init_plan_togle_switcher();
})

function expand_plan_items($plansOpen,          $containsClose, $btnBlock,
                           $plansItemInnerLeft, $plansTab,      $caretIcon,
                           $plansToggle) {
  $plansOpen.addClass('plans-open');
  // $newtestplanlinkClose.addClass('newtestplanlink-close');
  $containsClose.addClass('contains-close');
  $btnBlock.addClass('open-addTestPlan-block');
  $plansItemInnerLeft.addClass('grow');
  $plansTab.addClass('expanded');
  $plansToggle.addClass('open');
  $caretIcon.removeClass('fa-caret-right').addClass('fa-caret-left');
};

function narrow_plan_items($plansOpen,          $containsClose, $btnBlock,
                           $plansItemInnerLeft, $plansTab,      $caretIcon,
                           $plansToggle) {
  $plansOpen.removeClass('plans-open');
  // $newtestplanlinkClose.removeClass('newtestplanlink-close');
  $containsClose.removeClass('contains-close');
  $btnBlock.removeClass('open-addTestPlan-block');
  $plansItemInnerLeft.removeClass('grow');
  $plansTab.removeClass('expanded');
  $plansToggle.removeClass('open');
  $caretIcon.removeClass('fa-caret-left').addClass('fa-caret-right');
};
