Vrdb.Views.Entities ||= {}

class Vrdb.Views.Entities.EntityMapPopupView extends Backbone.View
  el: "#map_popup"

  initialize: (entity) ->
    @entity = entity

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
    # When the country is the current entity
    if !@country.value?
      html = "#{@countryHeader(@country)[0]} <a class=\"funder\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a>"
    else if @perspective == 'self'
      if @country.value == 0
        html = "#{@countryHeader(@country)[0]} <a class=\"funder\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>"
        html += "No contributions reported"
      else if @country.value < 0
        @country.value = Math.abs(@country.value)
        html = "#{@countryHeader(@country)[0]} <a class=\"funder\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>"
        html += "$#{@country.value}M from #{@country.name}, as reported by #{@entity.name}"
      else
        html = "#{@countryHeader(@country)[0]} <a class=\"funder\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>"
        html += "$#{@country.value}M to #{@country.name}, as reported by #{@entity.name}"
    else
      if @country.value == 0
        html = "#{@countryHeader(@country)[0]} <a class=\"funder\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>"
        html += "No contributions reported"
      else if @country.value < 0
        @country.value = Math.abs(@country.value)
        html = "#{@countryHeader(@country)[0]} <a class=\"recipient\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>"
        html += "$#{@country.value}M to #{@entity.name}, as reported by #{@country.name}"
      else
        html = "#{@countryHeader(@country)[0]} <a class=\"recipient\" href=\"/entities/#{@country.id_feed}\">#{@countryHeader(@country)[1]}</a><br/>"
        html += "$#{@country.value}M from #{@entity.name}, as reported by #{@country.name}"

    @$el.html(html)
