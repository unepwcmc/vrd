Vrdb.Views.Arrangements ||= {}

class Vrdb.Views.Arrangements.ArrangementView extends Backbone.View
  template: JST["backbone/templates/arrangements/arrangement"]
  template_second_row: JST["backbone/templates/arrangements/arrangement_second_row"]

  tagName: "tr"
  className: "first-row"

  render: ->
    @$el.html(@template(model: @model.toJSON(), period_interval: @model.period_interval(@model.collection.period_from, @model.collection.period_to), period_start: @model.period_start(@model.collection.period_from, @model.collection.period_to), amount_percentage: @model.amount_percentage() ))
    return this
    
  render_second_row: ->
    $("<tr class=\"second-row\" />").html(@template_second_row(model: @model.toJSON(), period_interval: @model.period_interval(@model.collection.period_from, @model.collection.period_to), period_start: @model.period_start(@model.collection.period_from, @model.collection.period_to), amount_percentage: @model.amount_percentage() ))
