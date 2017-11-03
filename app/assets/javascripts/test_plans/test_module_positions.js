TestModule.sortable = {
  init: function() {
    $('.sortable-container').sortable({
      connectWith: '.sortable-container',
      cursor: "move",
      items: '.test-module-sortable-item',
      revert: true,
      tolerance: 'pointer',
      placeholder: 'ui-state-hover',
      change: TestModule.sortable.calculate_state_hover_class,
      start: TestModule.sortable.start_action,
      stop: TestModule.sortable.stop_action,
      receive: TestModule.sortable.receive.action
    }).disableSelection();
  },

  calculate_state_hover_class: function() {
    if ($('.ui-state-hover').parent().hasClass('root')) {
      $('.ui-state-hover').removeClass('sub');
    } else if(!$('.ui-state-hover').hasClass('sub')) {
      $('.ui-state-hover').addClass('sub');
    }
  },

  start_action: function(event, ui) {
    if (!ui.item.hasClass('cases-info-item')) {
      ui.item.addClass('cases-info-item');
      ui.item.children().children().removeClass('sub');
    }
    TestModule.sortable.calculate_state_hover_class()
  },

  stop_action: function(event, ui) {
    if (!ui.item.parent().hasClass('root')) {
      ui.item.removeClass('cases-info-item');
      ui.item.children().children().addClass('sub');
    }
    TestModule.sortable.positions.update(ui.item);
    TestModule.sortable.jstree_position.update(ui.item);
  },

  receive: {
    action: function(event, ui) {
      if (!ui.sender.hasClass('root')) {
        TestModule.sortable.receive.case_counters.change_sender(ui.sender, ui.item)
      };
      if (!ui.item.parent().hasClass('root')) {
        TestModule.sortable.receive.case_counters.change_receiver(ui.item.parent(), ui.item)
      };
    },

    case_counters: {
      module_number_selector: '> .cases-info-item-inner > .module-item > .cases-test-header .number',

      change_receiver: function(receiver, item) {
        this.update(
          receiver.parents('.test-module-sortable-item'),
          this.retrieve_count(item)
        );
      },

      change_sender: function(sender, item) {
        this.update(
          sender.parents('.test-module-sortable-item'),
          -this.retrieve_count(item)
        );
      },

      update: function(parent_modules, counts) {
        parent_modules.find(this.module_number_selector).each(function(){
          number = $(this);
          number.text('(' + (TestModule.retrieve_cases_count(number.text()) + counts) + ')');
        });
      },

      retrieve_count: function(item) {
        return TestModule.retrieve_cases_count(item.find(this.module_number_selector).text());
      }
    }
  },

  jstree_position: {
    update: function(item) {
      positions = this.retrieve_position(item);
      if (positions) {
        TestModule.jstree.move_item(item.children().data('id'), positions[0].children().data('id'), positions[1])
      }
    },

    retrieve_position: function(item) {
      if (item.prev().length && !item.prev().hasClass('dummy-item')) {
        return [item.prev(), 'after'];
      } else if(item.next().length && !item.next().hasClass('dummy-item')) {
        return [item.next(), 'before'];
      } else if (!item.parent().hasClass('root')) {
        return [item.parents('.test-module-sortable-item').first(), 'last'];
      }
    }
  },

  positions: {
    params: {
      id: null,
      parent_id: null,
      positions: {}
    },

    update: function(item) {
      this.params.id = item.children().data('id');
      this.params.parent_id = item.parent().hasClass('root') ? null : item.parents('.cases-info-item-inner').first().data('id');

      item.parent().children().each(function(i){
        TestModule.sortable.positions.params.positions[$(this).children().data('id')] = i + 1;
      });
      $.ajax({
        type: 'PUT',
        url: '/test_module_positions/' + $('.sortable-container.root').data('test-plan-id'),
        data: this.params
      });
    }
  }
}