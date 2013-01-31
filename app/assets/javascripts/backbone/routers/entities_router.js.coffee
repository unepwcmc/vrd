class Vrdb.Routers.EntitiesRouter extends Vrdb.BaseRouter
  initialize: (options) ->
    # Base router
    super(options)

    @totals_by_institution = options.totals_by_institution 
    @total_funding_per_year_entity = options.total_funding_per_year_entity
    @max_contribution_year = options.max_contribution_year
    @arrangement_counts_by_action_category = options.arrangement_counts_by_action_category
    @entity = options.entity
    @reported_by = options.reported_by

  routes:
    "graphs_and_stats": "graphs_and_stats"
    "arrangements/t/:timespans/f/:funder/r/:recipient/a/:amounts/p/:page": "search"
    "arrangements": "arrangements_index"
    "introduction": "introduction"
    ".*": "introduction"

  introduction: (() ->
    already_ran = false

    return () ->
      # Code that always runs
      $('ul.nav-tabs > li > a[href="#tab_introduction"]').tab('show')

      # Code that runs only once
      return if already_ran
      already_ran = true

      # Initialize Map
      new Vrdb.Views.Entities.EntityMapView(@entity, @totals_by_institution, @cartodb_geom_table, @cartodb_point_table, @reported_by)
  )()

  graphs_and_stats: (() ->
    already_ran = false

    return () ->
      # Code that always runs
      $('ul.nav-tabs > li > a[href="#tab_graphs_and_stats"]').tab('show')

      # Code that runs only once
      return if already_ran
      already_ran = true

      window.total_funding_per_year_entity(@total_funding_per_year_entity, @max_contribution_year)
      window.counts_by_action_category_entity(@arrangement_counts_by_action_category)
      window.startFundingFlowGraph(@entity, @reported_by)
  )()

  arrangements_index: (() ->
    already_ran = false

    return () ->
      # Code that always runs
      $('ul.nav-tabs > li > a[href="#tab_arrangements"]').tab('show')

      # Code that runs only once
      return if already_ran
      already_ran = true

      # Arrangements table
      @view = new Vrdb.Views.Arrangements.IndexView(arrangements: @arrangements)
      $("#arrangements_table tbody").replaceWith(@view.render().el)
  )()
