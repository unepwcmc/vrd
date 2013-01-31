Vrdb.Views.Arrangements ||= {}

class Vrdb.Views.Arrangements.IndexView extends Backbone.View
  pagination_template: JST["backbone/templates/arrangements/pagination"]

  tagName: "tbody"

  events:
    'mouseenter tr': 'mouseenter'
    'mouseleave tr': 'mouseleave'

  mouseenter: (e) ->
    element = $(e.target).parents('tr') || $(e.target)
    element.addClass('hover')
    if element.hasClass('first-row')
      element.next().addClass('hover')
    else
      element.prev().addClass('hover')

  mouseleave: (e) ->
    element = $(e.target).parents('tr') || $(e.target)
    element.removeClass('hover')
    if element.hasClass('first-row')
      element.next().removeClass('hover')
    else
      element.prev().removeClass('hover')

  initialize: ->
    @options.arrangements.bind('reset', @render)

    # Pagination
    $("#arrangements_pagination").delegate('.prev a', 'click', @previous)
    $("#arrangements_pagination").delegate('.next a','click', @next)

  addAll: () =>
    @$el.empty()
    if @options.arrangements.length > 0
      @options.arrangements.each(@addOne)
    else
      @$el.html("<tr id=\"empty_arrangements_list\"><td colspan=\"4\">Your search has returned no results</td></tr>")
      $("#arrangements_pagination, #arrangements_footer").empty()

  addOne: (arrangement) =>
    view = new Vrdb.Views.Arrangements.ArrangementView({model : arrangement})
    @$el.append(view.render().el)
    # Hack to display second row per element
    @$el.append(view.render_second_row())

  render: =>
    $("#arrangements_pagination").html(@pagination_template(@options.arrangements.pageInfo()))
    $("#arrangements_footer").html("<tr><td colspan=\"3\">Total:</td><td>$#{Math.floor(@options.arrangements.total_amount * 100) / 100}M</td></tr>")
    @addAll()

    return this

  previous: =>
    @options.arrangements.previousPage()
    return false

  next: =>
    @options.arrangements.nextPage()
    return false
