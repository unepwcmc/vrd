Vrdb.Views.Arrangements ||= {}

class Vrdb.Views.Arrangements.MapDetailPopupView extends Backbone.View
  el: "#map_popup"

  countryHeader: (country) ->
    ["<img src=\"/assets/famfam/#{country.iso2.toLowerCase()}.png\"/>", "#{country.name}"]

  show: (country, perspective, position) =>
    if !@country? || @country.id_feed != country.id_feed
      @country = country
      @perspective = perspective
      @render()

    @$el.css
      left: position.x
      top: position.y
    @$el.show()

  hide: =>
    @$el.hide()

  render: ->
    financing_value = Math.floor(Math.abs(@country.value) * 100) / 100

    if !@country.value?
      html = "#{@countryHeader(@country)[0]} <a href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>"
      html += "Not involved in REDD+"
    else if @country.value == 0
      html = "#{@countryHeader(@country)[0]} <a href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>"
      html += "No contributions reported"
    else if @country.value < 0
      # Receiving
      reported_by = if @perspective == 'funders' then 'funders' else @country.name

      html = """#{@countryHeader(@country)[0]} <a class=\"recipient\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>
         Receiving $#{financing_value}M, as reported by #{reported_by}"""
    else
      # Funding
      reported_by = if @perspective == 'recipients' then 'recipients' else @country.name

      html = """#{@countryHeader(@country)[0]} <a class=\"funder\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>
        Funding $#{financing_value}M, as reported by #{reported_by}"""

    @$el.html(html)
