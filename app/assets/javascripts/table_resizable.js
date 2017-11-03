$(document).on('click', '.sortable', function(){
  columnable_id = $(this).parents('table').data('columnable')
  column = $(this).data('column')
  order =$(this).data('order') 
  $.ajax({
    type: 'PUT',
    url: '/column_visibilities/' + columnable_id + '/update_sort_order',
    data: { column: column, order: order }
  })
})

$(document).on('click', '.cancel_sort', function(){
  columnable_id = $(this).data('columnable')
  $.ajax({
    type: 'PUT',
    url: '/column_visibilities/' + columnable_id + '/update_sort_order'
  })
})

var onSlider = function(e){
    var columns = e.currentTarget.getElementsByTagName('th');
    var ranges = [], names = [], total = 0, i, column_size = {}, w, columnable_id;
    for(i = 0; i<columns.length; i++){
      column = columns[i]
      w = column.offsetWidth;
      ranges.push(w);
      total+=w;
      names.push(column.dataset['column']);
    }    
    for(i=0; i<columns.length; i++){    
      column_size[names[i]] = Math.round(100*ranges[i]/total)
    }
    columnable_id = e.currentTarget.dataset['columnable']
    $.ajax({
    type: 'PUT',
    url: '/column_visibilities/' + columnable_id + '/update_column_size',
    data: { column_size: column_size },
    success: function() {
      for (var key in column_size){
        class_name = e.currentTarget.querySelectorAll("[data-column='" + key + "']")[0].className
        $('.' + class_name).css('width', column_size[key] + '%')
      }
      table_resizable();
    }
  });
}

function table_resizable() {
  $(".resizable-table").colResizable({
    liveDrag:true, 
    onResize: onSlider,
    minWidth:30
  });
}


