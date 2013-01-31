Vrdb.Views.Arrangements ||= {}

class Vrdb.Views.Arrangements.IndexMapView extends Backbone.View
  el: '#map_canvas'

  cartoDbPointQueryTmpl: JST["backbone/templates/arrangements/country_map_query"]

  initialize: (reported_by, cartodb_geom_table, cartodb_point_table) ->
    @reported_by = reported_by
    @cartodb_geom_table = cartodb_geom_table
    @cartodb_point_table = cartodb_point_table

    @mapOptions.center = new L.LatLng(20, 0)
    @map = new L.Map(@$el[0], @mapOptions)

    @mapDetailView = new Vrdb.Views.Arrangements.MapDetailPopupView()

    @render()

  mapOptions:
    zoom: 2
    maxZoom: 6
    minZoom: 2
    scrollWheelZoom: false

  pointStyle: () ->
    "#countries_ccb_vrd_centroids {
       marker-fill: #FFFFFF;
       marker-opacity:0.7;
       marker-width:3;
       marker-line-color: #666666;
       marker-line-width:1;
       marker-line-opacity:0.1;
       marker-placement:point;
       marker-type:ellipse;
       marker-allow-overlap:true;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<0] {
       marker-fill: #488E6D;
       marker-line-color:#488E6D;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}>0] {
       marker-fill: #ED8277;
       marker-line-color:#ED8277;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}>500] {
       marker-width:18;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<=500] {
       marker-width:13;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<=100] {
       marker-width:9;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<=50] {
       marker-width:5;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<=1] {
       marker-width:4;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}=0] {
       marker-width:3;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<0] {
       marker-width:4;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<=-1] {
       marker-width:6;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<=-50] {
       marker-width:9;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<=-100] {
       marker-width:15;
    }
    #countries_ccb_vrd_centroids[total_by#{@reported_by}<=-500] {
       marker-width:18;
    }
    "

  render: =>
    # Country geom base layer
    cartodbLayerAddress = "http://carbon-tool.cartodb.com/tiles/#{@cartodb_geom_table}/{z}/{x}/{y}.png"

    tileLayer = new L.TileLayer(cartodbLayerAddress)
    @map.addLayer(tileLayer)

    # Varying circle layer
    cartodbLayerAddress = "http://carbon-tool.cartodb.com/tiles/#{@cartodb_point_table}/{z}/{x}/{y}.png"

    pointLayer = new L.CartoDBLayer(
      map: @map
      user_name: "carbon-tool"
      table_name: @cartodb_point_table
      query: "SELECT * FROM {{table_name}}"
      tile_style: @pointStyle()
      interactivity: "id_feed, total_by#{@reported_by}, name, iso2"
      featureOver: (ev, latlng, position, data) =>
        $("#map_canvas").css('cursor', 'pointer')
        @mapDetailView.show(_.extend(data, {value: data["total_by#{@reported_by}"]}), @reported_by, position)
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
