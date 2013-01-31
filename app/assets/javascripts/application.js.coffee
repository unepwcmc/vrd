#= require jquery
#= require jquery-ui
#= require jquery_ujs
#= require highcharts
#= require graphs
#= require leaflet
#= require wax.leaf
#= require cartodb-leaflet
#= require cartodb-popup
#= require bootstrap
#= require underscore
#= require backbone
#= require backbone_rails_sync
#= require backbone_datalink
#= require backbone/vrdb

# Countries and Institutions - Modal boxes
$.expr[':'].Contains = jQuery.expr.createPseudo (arg) ->
  (elem) ->
    $(elem).text().toUpperCase().indexOf(arg.toUpperCase()) >= 0

$ ->
  $('.modal-body').each ->
    modalBody = $(this)

    modalBody.find('input').keyup ->
      filter = $(this).val()
      if filter
        modalBody.find('li').find("a:not(:Contains(#{filter}))").parent().hide()
        modalBody.find('li').find("a:Contains(#{filter})").parent().show()
      else
        modalBody.find('li').show()

  $.get '/countries', (data) -> $('#countries-modal').html(data)
  $.get '/institutions', (data) -> $('#institutions-modal').html(data)

  $('.modal-body form').submit -> return false

  $('#map_canvas').on 'click', '#cartodb_logo', ->
    return false

  $('.modal').on 'shown', -> $(this).find('input').focus()
