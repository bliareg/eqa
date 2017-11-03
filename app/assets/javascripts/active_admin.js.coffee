#= require active_admin/base
#= require highcharts
#= require loader
#= require chartkick
#= require chosen-jquery

@chosenify = (entry) ->
  entry.chosen
    allow_single_deselect: true

$ ->
  chosenify $(".chosen")

  $("form.formtastic .inputs .has_many").click ->
    $(".chosen").chosen
  if location.href.match(/except_tm_in/)
    $('input#q_except_tm_true').attr 'checked', 'checked'
allow_single_deselect: true
