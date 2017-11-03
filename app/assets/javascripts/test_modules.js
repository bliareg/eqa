var TestModule = {
  init: function() {
    this.sortable.init();
  },

  carets: {
    init: function() {
      $(document).on('click', '.cases-test .test-caret', function () {
        $(this).parent().next().toggleClass('open');
        $(this).parents('.cases-info-item-inner').first().toggleClass('open');
        $(this).toggleClass('caret-down');
      });
    }
  },

  jstree: {
    id_prefix: 'jstree_test_module_',
    html_instance: null,
    instance: null,

    init: function(data) {
      this.html_instance = $('#jstree');

      this.html_instance.jstree({
        "core" : {
          "check_callback" : true,
          "data" : data
        },
        "plugins" : [ "contextmenu",  "dnd"]
      }).on('ready.jstree', function() {
        TestModule.jstree.instance = $(this).jstree();
        TestModule.jstree.anchor.init();
      });
    },

    create_item: function(test_module_node) {
      this.instance.create_node(test_module_node.parent, test_module_node, 'last');
    },

    rename_item: function(test_module_id, new_name) {
      this.instance.rename_node(this.id_prefix + test_module_id, new_name);
    },

    delete_item: function(test_module_id) {
      this.instance.delete_node(this.id_prefix + test_module_id);
    },

    move_item: function(test_module_id, element_id, position) {
      this.instance.move_node(this.id_prefix + test_module_id, this.id_prefix + element_id, position || 'last');
    },

    anchor: {
      init: function() {
        TestModule.jstree.html_instance.on('click' , '.jstree-anchor', function(){
          var test_module_id = $(this).data('id');

          if (test_module_id) { TestModule.jstree.anchor.click_action(test_module_id) };
        });
      },

      click_action: function(test_module_id) {
        var $test_module = $('.testPlans .cases .cases-info-item-inner[data-id=' + test_module_id + ']');

        this.open_target_module($test_module);
        this.scroll_to_target_module($test_module)
      },

      open_target_module: function($test_module) {
        while ($test_module && $test_module.length){
          $test_module.addClass('open');
          $test_module.find('.test-caret').addClass('caret-down');
          $test_module = $test_module.parents('.cases-info-item-inner');
        }
      },

      scroll_to_target_module: function($test_module) {
        target_module = $test_module[0];
        $scroll = $test_module.parents(".mCustomScrollbar").first();

        target_module ? $scroll.mCustomScrollbar('scrollTo', target_module) : false;
      }
    }
  },

  retrieve_cases_count: function(number) {
    return parseInt(number.substring(1, number.length-1));
  }
}

TestModule.carets.init();
