# First graph (total funding by type overview)
window.total_funding_by_type_overview = (data) ->
  totalFundingByTypeGraph = new Highcharts.Chart(
    chart:
      renderTo: "total_funding_by_type_overview"
      type: "bar"

    title:
      text: null

    xAxis:
      categories: ["Funder countries to REDD+ countries", "Funder countries to institutions", "Institutions to institutions", "Institutions to REDD+ countries", "Internal funding with benefits to REDD+ countries", "Domestic funding", "Outgoing funding (unspecified or multiple recipients)"]
      title:
        text: null
      labels:
        style:
          color: '#3cafa2'
          fontWeight: 'normal'
      gridLineColor: "#dcdcdc"

    yAxis:
      min: 0
      title:
        text: "Millions of USD"
        style:
          color: '#3cafa2'
          fontWeight: 'normal'
      labels:
        overflow: "justify"
      gridLineColor: "#dcdcdc"

    tooltip:
      formatter: ->
        "<b>#{@x}</b><br/>$#{Highcharts.numberFormat(@y, 0)} M"

    legend:
      enabled: false

    credits:
      enabled: false

    plotOptions:
      bar:
        animation: false
        shadow: false
        borderWidth: 0
        color: '#9196c2'

    series: [{
      name: "Millions USD"
      data: data
    }]
  )

# Second graph (total funding per year overview)
window.total_funding_per_year_overview = (data) ->
  years = for year, contribution of data.contributions
    year

  domestic_contributions = for year, contribution of data.contributions
    contribution.domestic

  contributions = for year, contribution of data.contributions
    contribution.non_domestic

  new Highcharts.Chart
    chart:
      renderTo: "total_funding_per_year_overview"
      type: "column"
      margin: [50, 50, 100, 80]

    colors: ['#aa4643', '#9196c2']

    title:
      text: null

    xAxis:
      categories: years
      labels:
        style:
          color: "#989898"
      gridLineColor: "#dcdcdc"

    yAxis:
      min: 0
      title:
        text: "Millions of USD"
        style:
          color: '#3cafa2'
          fontWeight: 'normal'

    legend:
      enabled: true
      align: 'right'
      verticalAlign: 'top'

    plotOptions:
      column:
        stacking: 'normal'
        animation: false
        shadow: false
        borderWidth: 0

    tooltip:
      formatter: ->
        "<b>#{@series.name} in #{@x}</b><br/>$#{Highcharts.numberFormat(@y, 0)} M"

    series: [{
      name: 'Domestic',
      data: domestic_contributions
    }, {
      name: data.non_domestic_flow
      data: contributions
    }]

# Third graph (total funding per region overview)
window.total_funding_per_region_overview = (data) ->
  years = for year, contribution of data.contributions
    year

  domestic_contributions = for year, contribution of data.contributions
    contribution.domestic

  contributions = for year, contribution of data.contributions
    contribution.non_domestic

  new Highcharts.Chart
    chart:
      renderTo: "total_funding_per_region_overview"
      type: "column"
      margin: [50, 50, 100, 80]

    colors: ['#aa4643', '#9196c2']

    title:
      text: null

    xAxis:
      categories: years
      labels:
        style:
          color: "#989898"
      gridLineColor: "#dcdcdc"

    yAxis:
      min: 0
      title:
        text: "Millions of USD"
        style:
          color: '#3cafa2'
          fontWeight: 'normal'

    legend:
      enabled: true
      align: 'right'
      verticalAlign: 'top'

    plotOptions:
      column:
        stacking: 'normal'
        animation: false
        shadow: false
        borderWidth: 0

    tooltip:
      formatter: ->
        "<b>#{@series.name} in #{@x}</b><br/>$#{Highcharts.numberFormat(@y, 0)} M"

    series: [{
      name: 'Domestic',
      data: domestic_contributions
    }, {
      name: data.non_domestic_flow
      data: contributions
    }]

# Fourth graph (counts by action category)
window.counts_by_action_category_overview = (data) ->
  categories = []
  values = []
  for key, value of data
    categories.push(key)
    values.push(value)

  new Highcharts.Chart(
    chart:
      renderTo: "counts_by_action_category_overview"
      type: "bar"

    title:
      text: ""

    xAxis:
      categories: categories
      title:
        text: null
      labels:
        style:
          color: '#3cafa2'
          fontWeight: 'normal'
      gridLineColor: "#dcdcdc"

    yAxis:
      min: 0
      title:
        text: "Number of arrangements"
        style:
          color: '#3cafa2'
          fontWeight: 'normal'
      gridLineColor: "#dcdcdc"
      labels:
        overflow: "justify"

    tooltip:
      formatter: ->
        "<b>#{@x}</b><br/>#{@y}"

    plotOptions:
      bar:
        animation: false
        shadow: false
        borderWidth: 0
        color: '#9196c2'

    legend:
      enabled: false

    credits:
      enabled: false

    series: [
      name: "Number of arrangements"
      data: values
    ]
  )

# ENTITIES

# First graph (total funding per year entity)
window.total_funding_per_year_entity = (data, max_year) ->
  years = [Math.min(2009, parseInt(_.keys(data['series'])[0]))..max_year]

  receiving_contributions = for year in years
    contribution = data['series'][year]
    if contribution && contribution.incoming
      contribution.incoming
    else
      0

  funding_internal_domestic_unspecified_contributions = for year in years
    contribution = data['series'][year]
    if contribution && contribution.internal_domestic_unspecified
      contribution.internal_domestic_unspecified
    else
      0

  funding_contributions = for year in years
    contribution = data['series'][year]
    if contribution && contribution.outgoing
      contribution.outgoing
    else
      0

  if data['categories'].length == 2
    colors = ['#488e6d', '#ed8277']
    series = [
        name: data['categories'][0]
        data: receiving_contributions
        stack: 'incoming'
      ,
        name: data['categories'][1]
        data: funding_contributions
        stack: 'outgoing'
      ]
  else
    colors = ['#488e6d', '#aa4643', '#ed8277']
    series = [
        name: data['categories'][0]
        data: receiving_contributions
        stack: 'incoming'
      ,
        name: data['categories'][1]
        data: funding_contributions
        stack: 'outgoing'
      ,
        name: data['categories'][2]
        data: funding_internal_domestic_unspecified_contributions
        stack: 'outgoing'
      ]

  new Highcharts.Chart
    chart:
      renderTo: "total_funding_per_year_entity"
      type: "column"
      margin: [50, 50, 100, 80]

    colors: colors

    title:
      text: null

    xAxis:
      categories: years
      labels:
        style:
          color: "#989898"
      gridLineColor: "#dcdcdc"

    yAxis:
      min: 0
      title:
        text: "Millions of USD"
        style:
          color: '#3cafa2'
          fontWeight: 'normal'

    legend:
      enabled: true
      align: 'right'
      verticalAlign: 'top'

    plotOptions:
      column:
        animation: false
        shadow: false
        borderWidth: 0
        stacking: 'normal'

    tooltip:
      formatter: ->
        "<b>In #{@x}</b><br/>$#{Highcharts.numberFormat(@y, 0)} M"

    series: series

# Second graph (financing flows entity)

# Third graph (counts by action category entity)
window.counts_by_action_category_entity = (data) ->
  categories = []
  incoming_values = []
  outgoing_values = []
  for key, values of data
    categories.push(key)
    incoming_values.push(values.incoming)
    outgoing_values.push(values.outgoing)

  new Highcharts.Chart(
    chart:
      renderTo: "counts_by_action_category_entity"
      type: "bar"
      margin: [50, 50, 50, 250]

    colors: ['#488e6d', '#aa4643']

    title:
      text: ""

    xAxis:
      categories: categories
      title:
        text: null
      labels:
        style:
          color: '#3cafa2'
          fontWeight: 'normal'
      gridLineColor: "#dcdcdc"

    yAxis:
      min: 0
      allowDecimals: false
      title:
        text: "Number of arrangements"
        style:
          color: '#3cafa2'
          fontWeight: 'normal'
      gridLineColor: "#dcdcdc"
      labels:
        overflow: "justify"

    tooltip:
      formatter: ->
        "<b>#{@x}</b><br/>#{@y}"

    plotOptions:
      bar:
        animation: false
        shadow: false
        borderWidth: 0

    legend:
      enabled: true
      align: 'center'
      verticalAlign: 'top'
        
    credits:
      enabled: false

    series: [
      name: "Recipient"
      data: incoming_values
    ,
      name: "Funder"
      data: outgoing_values
    ]
  )
