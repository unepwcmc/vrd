class AnnualFinancing < ActiveRecord::Base
  # Associations
  belongs_to :arrangement

  class << self
    # Overview page method to return funder countries to multilateral institutions funding
    def funder_countries_to_multilateral_institutions_funding(reported_by)
      arrangement_type = (reported_by == 'funders' ? 'outgoing' : 'incoming')

      joins(arrangement: [:reporting_institution, :reported_on_institution])
        .where("institutions.institution_type = ?", (reported_by == 'funders' ? 'COUNTRY' : 'INTERGOVERNMENTAL_INSTITUTION'))
        .where("reported_on_institutions_arrangements.institution_type = ?", (reported_by == 'recipients' ? 'COUNTRY' : 'INTERGOVERNMENTAL_INSTITUTION'))
        .where(arrangements: {arrangement_type: arrangement_type})
        .sum(:contribution)
    end

    # Overview page method to return multilateral institutions to REDD+ countries funding
    def multilateral_institutions_to_redd_countries_funding(reported_by)
      arrangement_type = (reported_by == 'funders' ? 'outgoing' : 'incoming')

      joins(arrangement: [:reporting_institution, :reported_on_institution])
        .where("institutions.institution_type = ?", (reported_by == 'funders' ? 'INTERGOVERNMENTAL_INSTITUTION' : 'COUNTRY'))
        .where("reported_on_institutions_arrangements.institution_type = ?", (reported_by == 'recipients' ? 'INTERGOVERNMENTAL_INSTITUTION' : 'COUNTRY'))
        .where(arrangements: {arrangement_type: arrangement_type})
        .sum(:contribution)
    end

    # Overview page method to return funder countries to REDD+ countries funding
    def funder_countries_to_redd_plus_countries_funding(reported_by)
      arrangement_type = (reported_by == 'funders' ? 'outgoing' : 'incoming')

      joins(arrangement: [:reporting_institution, :reported_on_institution])
        .where("institutions.institution_type = ?", 'COUNTRY')
        .where("reported_on_institutions_arrangements.institution_type = ?", 'COUNTRY')
        .where(arrangements: {arrangement_type: arrangement_type})
        .sum(:contribution)
    end

    # Total funding per year for the overview page's graph
    def total_funding_per_year_overview(reported_by)
      arrangement_type = (reported_by == 'funders' ? 'outgoing' : 'incoming')

      non_domestic = joins(arrangement: [:reporting_institution, :reported_on_institution])
        .where("institutions.institution_type IN (?)", (reported_by == 'funders' ? %w( COUNTRY INTERGOVERNMENTAL_INSTITUTION INTERNATIONAL_NON_GOVERNMENTAL_INSTITUTION NATIONAL_NON_GOVERNMENTAL_INSTITUTION PRIVATE_SECTOR_ENTITY ) : 'COUNTRY'))
        .where("reported_on_institutions_arrangements.institution_type IN (?)", (reported_by == 'recipients' ? %w( COUNTRY INTERGOVERNMENTAL_INSTITUTION INTERNATIONAL_NON_GOVERNMENTAL_INSTITUTION NATIONAL_NON_GOVERNMENTAL_INSTITUTION PRIVATE_SECTOR_ENTITY ) : 'COUNTRY'))
        .where(arrangements: {arrangement_type: arrangement_type})
        .order(:year).group(:year)
        .sum(:contribution)

      domestic = joins(arrangement: [:reporting_institution, :reported_on_institution])
        .where("institutions.institution_type = ?", 'COUNTRY')
        .where("reported_on_institutions_arrangements.institution_type = ?", 'COUNTRY')
        .where(arrangements: {arrangement_type: 'domestic'})
        .order(:year).group(:year)
        .sum(:contribution)

      contributions = {}
      non_domestic.map do |year, non_domestic|
        contributions[year] = {non_domestic: non_domestic, domestic: 0}
        contributions[year][:domestic] = domestic[year] if domestic.has_key?(year)
      end

      {non_domestic_flow: arrangement_type.humanize, contributions: contributions}
    end

    def total_funding_per_region_overview(reported_by)
      arrangement_type = (reported_by == 'funders' ? 'outgoing' : 'incoming')

      if reported_by == 'funders'
        institution = {reported_on_institution: :region}
      else
        institution = {reporting_institution: :region}
      end

      non_domestic = joins(arrangement: institution)
        .where(arrangements: {arrangement_type: arrangement_type})
        .group('regions.name')
        .sum(:contribution)

      domestic = joins(arrangement: institution)
        .where(arrangements: {arrangement_type: 'domestic'})
        .group('regions.name')
        .sum(:contribution)

      contributions = {}
      non_domestic.map do |year, non_domestic|
        contributions[year] = {non_domestic: non_domestic, domestic: 0}
        contributions[year][:domestic] = domestic[year] if domestic.has_key?(year)
      end

      {non_domestic_flow: arrangement_type.humanize, contributions: contributions}
    end

    # Returns all AnnualFinancings with a given ISO2 code and a role
    # excluding domestic finance
    def fusion_tables_query(iso2, received_or_funded, reporter_role)
      arrangement_types = []

      if received_or_funded == 'received'
        country_role = (reporter_role == 'funder' ? :reported_on_institutions : :reporting_institutions)
        arrangement_types.push 'domestic'
      elsif received_or_funded == 'funded'
        country_role = (reporter_role == 'funder' ? :reporting_institutions : :reported_on_institutions)
        arrangement_types.push 'internal'
        arrangement_types.push 'unspecified' if reporter_role == 'funder'
      else
        raise "Must specify 'received' or 'funded', #{received_or_funded} is unnacceptable"
      end

      arrangement_types.push(reporter_role == 'funder' ? 'outgoing' : 'incoming')

      # Join relevant tables, named
      joins = "INNER JOIN arrangements ON arrangements.id = annual_financings.arrangement_id "
      joins << Arrangement.named_join_reporting_institution
      joins << Arrangement.named_join_reported_on_institution

      joins(joins)
        .where("reporting_institutions.institution_type = 'COUNTRY' ")
        .where("#{country_role}.iso2 ILIKE ?", iso2)
        .where("arrangement_type IN (?)", arrangement_types)
    end

    def total_funding_from_and_to(from, to, reporters_role)
      reporters_role = reporters_role.to_sym
      joins = 'INNER JOIN arrangements ON arrangements.id = annual_financings.arrangement_id '
      joins << Arrangement.named_join_reporting_institution
      joins << Arrangement.named_join_reported_on_institution

      query = joins(joins).
        where(["arrangements.arrangement_type = ?", (reporters_role == :funders ? 'outgoing' : 'incoming')])
      if (reporters_role == :funders ? from.to_sym == :country : to.to_sym == :country )
        query = query.where(["reporting_institutions.institution_type = ?", 'COUNTRY'])
      else
        query = query.where(["reporting_institutions.institution_type != ?", 'COUNTRY'])
      end
      if (reporters_role == :funders ? to.to_sym == :country : from.to_sym == :country )
        query = query.where(["reported_on_institutions.institution_type = ?", 'COUNTRY'])
      else
        query = query.where(["reported_on_institutions.institution_type != ?", 'COUNTRY'])
      end
      query.sum(:contribution)
    end

    def total_funding_internal_to_redd_plus_countries
      joins(:arrangement)
        .where(arrangements: {arrangement_type: 'internal'})
        .sum(:contribution)
    end

    def total_funding_domestic_funding
      joins(:arrangement)
        .where(arrangements: {arrangement_type: 'domestic'})
        .sum(:contribution)
    end

    def total_funding_unspecified_flow
      joins(:arrangement)
        .where(arrangements: {arrangement_type: 'unspecified'})
        .sum(:contribution)
    end

    def total_funding_by_type(reported_by)
      [
        total_funding_from_and_to(:country, :country, reported_by),
        total_funding_from_and_to(:country, :institution, reported_by),
        total_funding_from_and_to(:institution, :institution, reported_by),
        total_funding_from_and_to(:institution, :country, reported_by),
        total_funding_internal_to_redd_plus_countries,
        total_funding_domestic_funding,
      ].tap { |a| a << total_funding_unspecified_flow if reported_by == 'funders' }
    end
  end
end
