class Vrdb.Routers.ArrangementsRouter extends Vrdb.BaseRouter
  routes:
    "graphs_and_stats": "graphs_and_stats"
    "arrangements/t/:timespans/f/:funder/r/:recipient/a/:amounts/p/:page": "search"
    "arrangements": "arrangements_index"
    "fsf_report": "fsf_report"
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
      new Vrdb.Views.Arrangements.IndexMapView(@arrangements.reported_by, @cartodb_geom_table, @cartodb_point_table)
  )()

  graphs_and_stats: (() ->
    already_ran = false

    return () ->
      # Code that always runs
      $('ul.nav-tabs > li > a[href="#tab_graphs_and_stats"]').tab('show')

      # Code that runs only once
      return if already_ran
      already_ran = true

      # Initialize Graphs
      window.total_funding_by_type_overview(window.VRD.total_funding_by_type_overview)
      window.total_funding_per_year_overview(window.VRD.total_funding_per_year_overview)
      window.total_funding_per_region_overview(window.VRD.total_funding_per_region_overview)
      window.counts_by_action_category_overview(window.VRD.counts_by_action_category_overview)
  )()

  fsf_report: ->
    $('ul.nav-tabs > li > a[href="#tab_fsf_report"]').tab('show')

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
