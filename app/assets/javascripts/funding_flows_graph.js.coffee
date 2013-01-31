#= require d3.v2

loading_timer = null
returning_back = false
w = 700
h = 700
w2 = w / 2
h2 = h / 2
z = d3.scale.category20c()
i = 0

# -- settings
settings =
  MAIN_BALL_RADIO: 250
  MAX_LINE_SIZE: 60

# -- model
entityIdFeed = null
perspective = null
countryData = {}
allCountries = []
allCountriesByIdFeed = {}

svg = undefined
lines = undefined
tooltip = undefined
order_i = 0

class Country
  constructor: (data, index) ->
    for key, value of data
      @[key] = value
    @idx = index

  # Start position of the country line
  # F is value
  position: (f) ->
    f = 1  if f is `undefined`
    x: f * settings.MAIN_BALL_RADIO * Math.cos(angleFromIdx(@idx))
    y: f * settings.MAIN_BALL_RADIO * Math.sin(angleFromIdx(@idx))

  angle: ->
    angleFromIdx @idx

  # End position of the country line
  # v is offset
  endPosition: (v) ->
    v = 0  if v is `undefined`
    # Comment these lines if you want variable heights back
    if v != 0
      v = if v > 0 then 0.5 else -0.5
    x: (settings.MAIN_BALL_RADIO + v * settings.MAX_LINE_SIZE) * Math.cos(angleFromIdx(@idx))
    y: (settings.MAIN_BALL_RADIO + v * settings.MAX_LINE_SIZE) * Math.sin(angleFromIdx(@idx))

# Positions elements equally spaced around a circle
angleFromIdx = (i) ->
  -Math.PI / 2 + (i) * 2 * Math.PI / allCountries.length

window.startFundingFlowGraph = (entity, perspective) ->
  entityIdFeed = entity.id_feed
  perspective = perspective

  loading false

  svg = d3.select("#funding-flow-graph").append("svg:svg").attr("width", w).attr("height", h).attr("id", "svg")

  # Load countries
  d3.json "/entities/#{entityIdFeed}/funders_and_recipients.json", (data) ->
    loading true

    # Setup drawing elements
    svg.selectAll("g").remove()
    lines = svg.append("svg:g").attr("transform", "translate(" + w2 + "," + h2 + " )")

    tooltip = document.getElementById("funding-flow-tooltip")

    svg.style["position"] = "absolute"
    svg.style["z-index"] = 1000

    # Sort data
    order_by = ["institution_type"]
    strcmp = (a, b) ->
      (if a < b then -1 else ((if a > b then 1 else 0)))

    sourceCountry = _.find(data, (obj, i) ->
      if obj.id_feed == entityIdFeed
        data.splice(i,1)
    )

    rows = data.sort((a, b) ->
      strcmp b[order_by], a[order_by]
    )

    rows.unshift(sourceCountry)

    i = 0
    # turn rows into country objects, store in allCountries(ByIdFeed)
    while i < rows.length
      country = new Country(rows[i], i)

      allCountries[i] = country
      allCountriesByIdFeed[country.id_feed] = country
      ++i

    init_arrangements()

loading = (o) ->
  if o
    clearInterval loading_timer
    loading_timer = null
  else
    return  if loading_timer?
    loading_timer = setInterval(->
      svg.append("svg:circle").attr("r", 2).attr("cx", w2).attr("cy", h2).style("fill", "#000").style("fill-opacity", 0.5).transition().duration(2000).ease(Math.sqrt).attr("r", 100).style("fill-opacity", 1e-6).remove()
    , 600)

# Populates country data and starts the graph
init_arrangements = () ->
  loading false

  # Remove all current link paths, if any
  lines.selectAll("path.link").remove()

  sql = "/entities/#{entityIdFeed}/arrangement_totals_with_indirect.json"
  d3.json sql, (data) ->
    loading true
    i = 0

    maxTotal = d3.max(data, (d) ->
      Math.abs(d.total)
    )

    scaledTotal = maxTotal*30
    while i < data.length
      country = data[i]

      # Pre logarithm wrangling
      value = country.total
      if value > 0
        value = Math.abs(value*30)
        value = 1.01 if value < 1
      else if value < 0
        value = Math.abs(value*30)
        value = -1 if value > 0
      else
        value = 1

      # Build country data
      countryData[country.to_id_feed] =
        idx: i
        id_feed: country.to_id_feed
        value: if country.total != 0 then Math.log(value)/Math.log(scaledTotal) else 0
        type: if country.total < 0 then "funder" else "receiver"
        total: country.total
        links: []

      ++i

    start()

fade = (opacity, ttt, t) ->
  A = lines.selectAll("line.country").filter((d) ->
    d.iso isnt t.iso
  ).transition()
  A = A.delay(1000)  if returning_back
  A.transition().duration(ttt).style "opacity", opacity

colorByType = (t) ->
  return "#52afce"  if t is "funder"
  "#80ba47"

lineColor = (fromEntity, funding) ->
  if fromEntity == entityIdFeed # Direct funding
    return "#52afce" if funding > 0
    return "#80ba47"
  else
    return "#db7b41"

start = () ->
  # Get country link JSON and show the links
  showCountryLinks = (sourceCountry) ->
    loading false
    renderCountries()
    d3.json "/entities/#{entityIdFeed}/arrangement_totals_with_indirect.json", (links) ->
      loading true

      max_sum = d3.max(links, (a) ->
        total = -a.total  if (a.total < 0)

        total
      )

      lines.selectAll("path.link").remove()
      #'M 0,420 C 110,220 220,145 0,0'
      lines.selectAll("path.link").data(links.filter((d) ->
        return false  if d.to_id_feed is d.from_id_feed

        allCountriesByIdFeed[d.to_id_feed] isnt `undefined`
      )).enter().append("path").attr("class", "link").attr("d", (d) ->
        cd = countryData[d.from_id_feed]
        f = -(cd.value)
        f = 0 if cd.type == 'receiver'
        op = allCountriesByIdFeed[d.from_id_feed].endPosition(f)

        tp = allCountriesByIdFeed[d.to_id_feed].endPosition()
        s = "M " + op.x + "," + op.y
        e = "C 0,0 0,0 " + tp.x + "," + tp.y
        s + " " + e
      ).attr("fill", "none").attr("stroke", (d) ->
        lineColor(d.from_id_feed, d.total)
      ).attr("stroke-width", (d) ->
        width = countryData[d.to_id_feed].value*2
        # Higher minimum width for direct funding
        minWidth = if d.from_id_feed != entityIdFeed then 1 else 1.4
        if width < minWidth then minWidth else width
      ).attr "opacity", (d) ->
        #opacity = 0.3 + 0.5 * d.total / max_sum
        opacity = 0.5
        if d.from_id_feed != entityIdFeed # indirect
          opacity *= 0.25
        else
          opacity *= 100
        if opacity < 0.12 then 0.12 else opacity

  renderCountries = ->
    returning_back = true
    lines.selectAll("line.country").data(allCountries).transition().attr("x2", (d) ->
      c = countryData[d.id_feed]
      v = c.value  if c
      if c.type == 'funder'
        v = -v

      d.endPosition(v).x
    ).attr("y2", (d) ->
      c = countryData[d.id_feed]
      v = c.value  if c
      if c.type == 'funder'
        v = -v

      d.endPosition(v).y
    ).each "end", ->
      returning_back = false

  showCountryDataTooltip = (d, e) ->
    data = countryData[d.id_feed]

    tooltip.style.display = "block"
    #tooltip.style.position = "absolute"
    tooltip.style["z-index"] = "20000"
    tooltip.innerHTML = "#{d.name}"
    tooltip.style.left = d3.event.clientX + 10 + "px"
    tooltip.style.top = d3.event.clientY + 10 + "px"
    fade .2, 50, d
    @style["cursor"] = "pointer"

  # Start the graph
  # Value bars
  lines.selectAll("line.country").data(allCountries, (d) ->
    d.iso
  ).enter()
    .append("svg:line")
    .attr("class", "country")
    .attr("id", (d) ->
      d.idx
    )
    .attr("x1", (d) ->
      # x of start of bar
      d.position().x
    )
    .attr("y1", (d) ->
      # y of start of bar
      d.position().y
    )
    .attr("x2", (d) ->
      # x of end of bar
      c = countryData[d.id_feed]
      v = c.value  if c
      d.endPosition(v).x
    )
    .attr("y2", (d) ->
      # y of end of bar
      c = countryData[d.id_feed]
      v = c.value if c
      d.endPosition(v).y
    )
    .attr("stroke", (d) ->
      colorByType countryData[d.id_feed].type
    )
    .attr("stroke-width", 5)
    .on("mouseover", showCountryDataTooltip)
    .on("mouseout", (d) ->
      #tooltip.style.display = "none"
      fade 1, 500, d
    )

  # Text labels
  lines.selectAll("text.country").data(allCountries, (d) ->
    d.iso
  ).enter()
    .append("text")
    .attr("x", (d) ->
      c = allCountriesByIdFeed[d.id_feed]
      nudge = 5
      nudge *= -1 if c.idx > (allCountries.length / 2)
      d.position().x + nudge
    )
    .attr("y", (d) ->
      d.position().y - 4
    )
    .attr("text-anchor", (d) ->
      c = allCountriesByIdFeed[d.id_feed]
      if c.idx > (allCountries.length / 2) then "end" else null
    ).attr("transform", (d) ->
      c = allCountriesByIdFeed[d.id_feed]
      position = d.position()
      angleInDegrees = angleFromIdx(c.idx) * 180 / Math.PI
      angleInDegrees += 180 if c.idx > (allCountries.length / 2)
      "rotate(#{angleInDegrees } #{position.x} #{position.y})"
    ).attr("font-size", "10")
    .attr("font-weight", (d) ->
      if d.id_feed == entityIdFeed then 'bold' else 'normal'
    ).text((d) ->
      c = allCountriesByIdFeed[d.id_feed]
      name = c.name
      if name.length > 16
        name = name.substring(0, 15) + "..."
      name
    )
    .on("mouseover", showCountryDataTooltip)

  # Render paths from the entity being viewed
  showCountryLinks allCountriesByIdFeed[entityIdFeed]
