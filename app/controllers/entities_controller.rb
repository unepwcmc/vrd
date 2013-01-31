class EntitiesController < ApplicationController
  caches_page :show, :countries, :institutions

  def show
    @reported_by = params[:reported_by] || default_institution_reported_by

    @institution = Institution.find_by_id_feed(params[:id])

    # Introduction
    @incoming_funding = @institution.incoming_funding(@reported_by)
    @domestic_funding = @institution.domestic_funding
    @outgoing_funding = @institution.outgoing_funding(@reported_by)
    @unspecified_funding = @institution.unspecified_recipients_funding(@reported_by)

    @self_has_reported = @institution.self_has_reported
    @funder_countries = @institution.funder_countries.count
    @redd_plus_countries = @institution.redd_plus_countries.count
    @funder_institutions = @institution.funder_institutions.count
    @private_sector_entities = @institution.private_sector_entities.count
    @total_arrangements = @institution.total_arrangements.count

    # Graphs & Statistics
    @total_funding_per_year_entity = @institution.arrangement_totals_by_year(@reported_by)
    @max_contribution_year = AnnualFinancing.maximum(:year)
    @arrangement_counts_by_action_category = @institution.arrangement_counts_by_action_category(@reported_by)

    # Map statistics
    @totals_by_institution = @institution.arrangement_totals_by_institution(@reported_by)

    # Arrangements list
    @arrangements_list_funders = @institution.arrangements_list_funders(@reported_by)
    @arrangements_list_recipients = @institution.arrangements_list_recipients(@reported_by)
    @arrangements_list = @institution.arrangements_list(@reported_by)

    # Number of arrangements with category
    @arrangements_with_category_as_recipient = @institution.arrangements_with_category(@reported_by, 'recipient').count
    @arrangements_with_category_as_funder = @institution.arrangements_with_category(@reported_by, 'funder').count
  end

  def countries
    @countries = Institution.countries_list
    render layout: false
  end

  def institutions
    @institutions = Institution.institutions_list
    render layout: false
  end

  def funders_and_recipients
    @institution = Institution.find_by_id_feed(params[:id])
    @reported_by = params[:reported_by] || default_institution_reported_by

    funders_and_recipients = @institution.funders_and_recipients(true).as_json

    respond_to do |format|
      format.json { render json: funders_and_recipients }
    end
  end

  def arrangement_totals
    @institution = Institution.find_by_id_feed(params[:id])
    reported_by = params[:reported_by] || default_institution_reported_by
    
    respond_to do |format|
      format.json { render json: @institution.arrangement_totals_array }
    end
  end

  def arrangement_totals_with_indirect
    @institution = Institution.find_by_id_feed(params[:id])
    reported_by = params[:reported_by] || default_institution_reported_by
    
    respond_to do |format|
      format.json { render json: @institution.arrangement_totals_array(true) }
    end
  end
end
