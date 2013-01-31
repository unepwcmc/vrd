class OverviewController < ApplicationController
  caches_page :index

  def index
    @reported_by = params[:reported_by] || default_reported_by

    # Funding flows diagram
    @funder_countries_to_multilateral_institutions_funding = AnnualFinancing.funder_countries_to_multilateral_institutions_funding(@reported_by)
    @multilateral_institutions_to_redd_countries_funding = AnnualFinancing.multilateral_institutions_to_redd_countries_funding(@reported_by)
    @funder_countries_to_redd_plus_countries_funding = AnnualFinancing.funder_countries_to_redd_plus_countries_funding(@reported_by)

    # The database currently holds information submitted by
    @funder_countries = Institution.funder_countries.count
    @redd_plus_countries = Institution.redd_plus_countries.count
    @overview_institutions = Institution.overview_institutions.count
    @private_sector_entities = Institution.private_sector_entities.count
    @redd_plus_arrangements = Arrangement.overview_redd_plus_arrangements

    # Graphs

    # First graph (total funding by type)
    @total_funding_by_type = AnnualFinancing.total_funding_by_type(@reported_by)

    # Second graph (total funding per year)
    @total_funding_per_year_overview = AnnualFinancing.total_funding_per_year_overview(@reported_by)

    # Third graph (total funding per region)
    @total_funding_per_region_overview = AnnualFinancing.total_funding_per_region_overview(@reported_by)

    # Fourth graph (counts by action category)
    @counts_by_action_category = Arrangement.counts_by_action_category(@reported_by)

    # Year range (for the text under graphs)
    @from_year = AnnualFinancing.minimum(:year)
    @to_year = AnnualFinancing.maximum(:year)

    # Arrangements list
    @arrangements_list_funders = Institution.overview_arrangements_list_funders(@reported_by)
    @arrangements_list_recipients = Institution.overview_arrangements_list_recipients(@reported_by)
    @arrangements_list = Arrangement.overview_list(@reported_by)
  end
end
