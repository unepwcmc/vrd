class Vrdb.Models.Arrangement extends Backbone.Model
  paramRoot: 'arrangement'

  defaults:
    id_feed: null
    period_from: null
    period_to: null
    title: null
    total_amount: null
    recipient: null
    funder: null

  period_interval: (from, to) =>
    final_from = (from || router.arrangements.period_from)
    final_to = (to || router.arrangements.period_to)
    total = final_to - final_from

    Math.round((Math.min(@get('period_to'), final_to) - Math.max(@get('period_from'), final_from)) / total * 70)

  period_start: (from, to) =>
    final_from = (from || router.arrangements.period_from)
    final_to = (to || router.arrangements.period_to)

    Math.round((Math.max(@get('period_from'), final_from) - final_from) / (final_to - final_from) * 70)

  amount_percentage: =>
    Math.floor(@get('total_amount') / router.amount_slider_max * 100)

class Vrdb.Collections.ArrangementsCollection extends Backbone.Collection
  model: Vrdb.Models.Arrangement

  parse: (resp) ->
    @reported_by = resp.reported_by
    @page = parseInt(resp.current_page)
    @pages = resp.pages
    @total = resp.total
    @maximum = resp.maximum
    @total_amount = resp.total_amount
    @institution_id = resp.institution_id if resp.institution_id
    resp.models

  url: ->
    params = 
      page: @page
      reported_by: @reported_by

    params.period_from = @period_from if @period_from
    params.period_to = @period_to if @period_to
    params.funder = @funder if @funder
    params.recipient = @recipient if @recipient
    params.amount_from = @amount_from if @amount_from
    params.amount_to = @amount_to if @amount_to
    params.institution_id = @institution_id if @institution_id

    "/arrangements?#{$.param(params)}"

  pageInfo: ->
    {
      page: @page
      pages: @pages
      total: @total
      maximum: @maximum
      prev: @page - 1
      next: @page + 1
    }

  goToPage: (page) ->
    if(page < 1 || page > @pages)
      return false
    @page = page

  nextPage: ->
    @goToPage(@page + 1)
    @updateUrlHash()

  previousPage: ->
    @goToPage(@page - 1)
    @updateUrlHash()

  # Filters
  filterByTimespan: (min, max) ->
    if(@period_from == min && @period_to == max)
      return false

    @period_from = min
    @period_to = max

    @updateUrlHash()

  filterByFunder: (funder) ->
    if(@funder == funder)
      return false

    @page = 1
    @funder = funder

    @updateUrlHash()

  filterByRecipient: (recipient) ->
    if(@recipient == recipient)
      return false

    @page = 1
    @recipient = recipient

    @updateUrlHash()

  filterByAmount: (min, max) ->
    if(@amount_from == min && @amount_to == max)
      return false

    @amount_from = min
    @amount_to = max

    @updateUrlHash()

  updateUrlHash: ->
    params = [
      'arrangements'
      't' # Timespan
      @period_from? && @period_to? && "#{@period_from}-#{@period_to}" || 'all'
      'f' # Funder
      @funder || 'all'
      'r' # Recipient
      @recipient || 'all'
      'a' # Amount
      @amount_from? && @amount_to? &&"#{@amount_from}-#{@amount_to}" || 'all'
      'p' # Page
      @page
    ]

    window.location.hash = params.join('/')
