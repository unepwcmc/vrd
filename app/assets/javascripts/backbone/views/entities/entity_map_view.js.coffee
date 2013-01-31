Vrdb.Views.Entities ||= {}

class Vrdb.Views.Entities.EntityMapView extends Backbone.View
  el: '#map_canvas'

  initialize: (entity, totals_by_institution, cartodb_geom_table, cartodb_point_table, perspective) ->
    @entity = entity
    @totals_by_institution = totals_by_institution
    @cartodb_geom_table = cartodb_geom_table
    @cartodb_point_table = cartodb_point_table
    @perspective = perspective

    @mapOptions.center = new L.LatLng(20, 0)
    @map = new L.Map(@$el[0], @mapOptions)

    @mapDetailView = new Vrdb.Views.Entities.EntityMapPopupView(@entity)

    @render()

  mapOptions:
    zoom: 2
    maxZoom: 6
    minZoom: 2
    scrollWheelZoom: false

  getMaxInstitutionTotal: () ->
    unless @maxInstitutionTotal?
      @maxInstitutionTotal = 0
      for institution, total of @totals_by_institution
        if institution != ''
          @maxInstitutionTotal = total if total > @maxInstitutionTotal
    @maxInstitutionTotal

  getMinInstitutionTotal: () ->
    unless @minInstitutionTotal?
      @minInstitutionTotal = 0
      for institution, total of @totals_by_institution
        if institution != ''
          @minInstitutionTotal = total if total < @minInstitutionTotal
    @minInstitutionTotal

  generateCartoCss: ->
    cartoCSS = 
      "##{@cartodb_point_table} {
         marker-fill: #FFFFFF;
         marker-opacity:0.7;
         marker-width:0;
         marker-line-color: #666666;
         marker-line-width:0;
         marker-line-opacity:0.3;
         marker-placement:point;
         marker-type:ellipse;
         marker-allow-overlap:true;
      }
      ##{@cartodb_point_table}[iso2='#{@entity.iso2}'] {
         marker-fill: #FFFFFF;
         marker-line-color:#AAAAAA;
         marker-line-width:2;
         marker-opacity:0.9;
         marker-line-opacity:0.9;
         marker-width:4;
      }"

    index = 0
    sizeScale = 8
    # Set bubble size and color explicitly
    categorizedInstitutions = {}
    for institution, total of @totals_by_institution
      if institution != ''
        # Insert into colour category
        if total > 0
          categorizedInstitutions['#488E6D'] ||= {}

          # Insert into size category
          if total > 4
            categorizedInstitutions['#488E6D'][total/sizeScale+4] ||= []
            categorizedInstitutions['#488E6D'][total/sizeScale+4].push institution
          else
            categorizedInstitutions['#488E6D'][4] ||= []
            categorizedInstitutions['#488E6D'][4].push institution
        else if total < 0
          categorizedInstitutions['#ED8277'] ||= {}
          if -4 < total < 0
            categorizedInstitutions['#ED8277'][4] ||= []
            categorizedInstitutions['#ED8277'][4].push institution
          else if total < -4
            categorizedInstitutions['#ED8277'][-total/sizeScale+4] ||= []
            categorizedInstitutions['#ED8277'][-total/sizeScale+4].push institution
        else
          categorizedInstitutions['#FFFFFF'] ||= {}
          categorizedInstitutions['#FFFFFF'][3] ||= []
          categorizedInstitutions['#FFFFFF'][3].push institution

    for color, institutionsBySize of categorizedInstitutions
      for size, institutions of institutionsBySize
        selectors = []
        for institution in institutions
          selectors.push "##{@cartodb_point_table}[iso2='#{institution}']"
        cartoCSS += selectors.join()
        cartoCSS += "{marker-fill:#{color}; marker-line-color:#{color}; marker-width:#{size};}"

    return cartoCSS

  render: =>
    # Country geom base layer
    cartodbLayerAddress = "http://carbon-tool.cartodb.com/tiles/#{@cartodb_geom_table}/{z}/{x}/{y}.png"

    tileLayer = new L.TileLayer(cartodbLayerAddress)
    @map.addLayer(tileLayer)

    # Bubble points layer
    cartodbLayerAddress = "http://carbon-tool.cartodb.com/tiles/#{@cartodb_point_table}/{z}/{x}/{y}.png"

    pointLayer = new L.CartoDBLayer(
      map: @map
      user_name: "carbon-tool"
      table_name: @cartodb_point_table
      query: "SELECT * FROM {{table_name}}"
      tile_style: @generateCartoCss()
      interactivity: "id_feed, iso2, name"
      featureOver: (ev, latlng, position, data) =>
        $("#map_canvas").css('cursor', 'pointer')
        @mapDetailView.show(_.extend(data, {value: @totals_by_institution[data.iso2]}), @perspective, position)
      featureOut: =>
        $("#map_canvas").css('cursor', '')
        @mapDetailView.hide()
      featureClick: (ev, latlng, position, data) =>
        window.location = "/entities/#{data.id_feed}"
      attribution: "CartoDB"
      auto_bound: false
    )
    @map.addLayer(pointLayer)

    return this
