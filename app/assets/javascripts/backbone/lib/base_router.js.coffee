class Vrdb.BaseRouter extends Backbone.Router
  initialize: (options) ->
    @arrangements = new Vrdb.Collections.ArrangementsCollection()
    @arrangements.reset @arrangements.parse(options.arrangements)
    @cartodb_geom_table = options.cartodb_geom_table
    @cartodb_point_table = options.cartodb_point_table

    # Select reported_by
    $(".reported_by .nav a").click ->
      window.location = "#{$(this).attr('href')}#{window.location.hash.split('/')[0]}"
      return false

    $(".reported_by a, #diagram a, .map_tooltip").tooltip({placement: 'left'})

    # Tabs
    if location.hash
      activeTab = $("[href=#tab_#{location.hash.split("#")[1].split("/")[0]}]")
      activeTab && activeTab.tab("show")

    $('body').on 'click.tab.data-api', '[data-toggle="tab"], [data-toggle="pill"]', (e) ->
      window.location.hash = e.target.href.split("#tab_")[1]

    # Filters
    @timespan_slider_min = options.arrangements.timespan.min || 2005
    @timespan_slider_max = options.arrangements.timespan.max || 2017
    
    $("#timespan_slider").slider
      range: true
      min: @timespan_slider_min
      max: @timespan_slider_max
      values: [@timespan_slider_min, @timespan_slider_max]
      slide: (event, ui) =>
        @updateTimespanRange(ui.values[0], ui.values[1])
        @arrangements.goToPage(1)
        return true
      change: (event, ui) =>
        @arrangements.filterByTimespan(ui.values[0], ui.values[1])
    @updateTimespanRange(@timespan_slider_min, @timespan_slider_max)

    @amount_slider_min = options.arrangements.amount.min || 0
    @amount_slider_max = options.arrangements.amount.max || 10

    $("#amount_slider").slider
      range: true
      min: @amount_slider_min
      max: @amount_slider_max
      values: [@amount_slider_min, @amount_slider_max]
      slide: (event, ui) =>
        @updateAmountRange(ui.values[0], ui.values[1])
        @arrangements.goToPage(1)
        return true
      change: (event, ui) =>
        @arrangements.filterByAmount(ui.values[0], ui.values[1])
    @updateAmountRange(@amount_slider_min, @amount_slider_max)

    $("#funder_id").change (event) =>
      @arrangements.filterByFunder($(event.target).val())

    $("#recipient_id").change (event) =>
      @arrangements.filterByRecipient($(event.target).val())

  search: (timespans, funder, recipient, amounts, page) ->
    @arrangements.page = parseInt(page)

    $('ul.nav-tabs > li > a[href="#tab_arrangements"]').tab('show')

    if timespans == 'all'
      $("#timespan_slider")
        .slider("values", 0, $("#timespan_slider").slider("option", "min"))
        .slider("values", 1, $("#timespan_slider").slider("option", "max"))
    else
      @arrangements.period_from = timespans.split('-')[0]
      @arrangements.period_to = timespans.split('-')[1]

      $("#timespan_slider")
        .slider("values", 0, timespans.split('-')[0])
        .slider("values", 1, timespans.split('-')[1])
      @updateTimespanRange(timespans.split('-')[0], timespans.split('-')[1])

    if funder == 'all'
      $("#funder_id").val('')
      @arrangements.funder = ''
    else
      $("#funder_id").val(funder)
      @arrangements.funder = funder

    if recipient == 'all'
      $("#recipient_id").val('')
      @arrangements.recipient = ''
    else
      $("#recipient_id").val(recipient)
      @arrangements.recipient = recipient

    if amounts == 'all'
      $("#amount_slider")
        .slider("values", 0, $("#amount_slider").slider("option", "min"))
        .slider("values", 1, $("#amount_slider").slider("option", "max"))
    else
      @arrangements.amount_from = amounts.split('-')[0]
      @arrangements.amount_to = amounts.split('-')[1]

      $("#amount_slider")
        .slider("values", 0, amounts.split('-')[0])
        .slider("values", 1, amounts.split('-')[1])
      @updateAmountRange(amounts.split('-')[0], amounts.split('-')[1])

    # Arrangements table
    @arrangements_index()

    @arrangements.fetch({add: false})

  updateTimespanRange: (min, max) =>
    $('#timespan_range').html("#{min} - #{max}")

  updateAmountRange: (min, max) =>
    $('#amount_range').html("$#{min}M - $#{max}M")
