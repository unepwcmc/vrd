class Institution < ActiveRecord::Base
  # Associations
  has_one :profile
  has_many :arrangements
  has_and_belongs_to_many :beneficiary_arrangements, class_name: 'Arrangement', join_table: 'beneficiary_countries', uniq: true

  belongs_to :region

  # Validations
  #validates :institution_type, inclusion: { in: %w(COUNTRY INTERGOVERNMENTAL_INSTITUTION INTERNATIONAL_NON_GOVERNMENTAL_INSTITUTION NATIONAL_NON_GOVERNMENTAL_INSTITUTION PRIVATE_SECTOR_ENTITY), allow_nil: true }

  # Scopes
  scope :countries, where(institution_type: 'COUNTRY')
  scope :institutions, where("institution_type != ?", 'COUNTRY')

  def country?
    institution_type == 'COUNTRY'
  end

  def institution?
    !country?
  end

  class << self
    def countries_list
      countries
        .includes(:arrangements, {profile: :arrangements})
        .select('name, id_feed')
        .where('arrangements.id IS NOT NULL OR arrangements_profiles.id IS NOT NULL')
        .order(:name)
    end

    def institutions_list
      institutions
        .includes(:arrangements, {profile: :arrangements})
        .select('name, id_feed')
        .where('arrangements.id IS NOT NULL OR arrangements_profiles.id IS NOT NULL')
        .order(:name)
    end

    # Overview page method to return funder countries
    def funder_countries
      includes({profile: :arrangements})
        .where('arrangements.id IS NOT NULL')
        .where("institution_type = ?", 'COUNTRY')
        .where("arrangement_type IN ('outgoing', 'internal') OR arrangement_type IS NULL")
    end

    # Overview page method to return REDD+ countries
    def redd_plus_countries
      includes({profile: :arrangements})
        .where('arrangements.id IS NOT NULL')
        .where("institution_type = ?", 'COUNTRY')
        .where("arrangement_type IN ('incoming', 'domestic')")
    end

    # Overview page method to return institutions
    def overview_institutions
      includes({profile: :arrangements})
        .where('arrangements.id IS NOT NULL')
        .where("institution_type IN ('INTERGOVERNMENTAL_INSTITUTION', 'INTERNATIONAL_NON_GOVERNMENTAL_INSTITUTION', 'NATIONAL_NON_GOVERNMENTAL_INSTITUTION')")
    end

    # Overview page method to return private sector entities
    def private_sector_entities
      includes({profile: :arrangements})
        .where('arrangements.id IS NOT NULL')
        .where("institution_type = ?", 'PRIVATE_SECTOR_ENTITY')
        .where("arrangement_type IN ('incoming', 'outgoing')")
    end

    def overview_arrangements_list_funders(reported_by)
      if reported_by == 'funders'
        include = {profile: :arrangements}
        arrangement_type = %w(outgoing domestic internal unspecified)
      else
        include = :arrangements
        arrangement_type = %w(incoming domestic internal)
      end

      includes(include)
        .where("arrangements.arrangement_type IN (?)", arrangement_type)
        .order('name')
        .map { |i| [i.name, i.id] }
    end

    def overview_arrangements_list_recipients(reported_by)
      if reported_by == 'funders'
        include = :arrangements
        arrangement_type = %w(outgoing domestic internal)

        if includes(include).where("arrangements.arrangement_type = ?", 'unspecified').count > 0
          unspecified_filter = [['Unspecified or multiple', 'unspecified']]
        else
          unspecified_filter = []
        end
      else
        include = {profile: :arrangements}
        arrangement_type = %w(incoming domestic internal)
        unspecified_filter = []
      end

      unspecified_filter + includes(include)
        .where("arrangements.arrangement_type in (?)", arrangement_type)
        .order('name')
        .map { |i| [i.name, i.id] }
    end
  end

  def funders(reported_by, include_domestic = false)
    
    if reported_by == 'self'
      include = {arrangements: :reporting_institution, profile: :arrangements}
      query = "(arrangements.arrangement_type in (#{"'domestic'," if include_domestic} 'unspecified', 'incoming') AND reporting_institutions_arrangements.id = :id) OR (arrangements_profiles.arrangement_type in (#{"'domestic'," if include_domestic} 'unspecified', 'outgoing') AND institutions.id = :id)"
    else
      include = [{profile: {arrangements: :reported_on_institution}}, :arrangements]
      query = "(arrangements.arrangement_type = 'outgoing' AND reported_on_institutions_arrangements.id = :id) OR (arrangements_institutions.arrangement_type = 'incoming' AND institutions.id = :id)"
    end

    Institution.includes(include).where(query, id: self.id)
  end

  def arrangements_list_funders(reported_by)
    funders(reported_by, true).select('name, id').order('institutions.name').map { |i| [i.name, i.id] }
  end

  def arrangements_list_recipients(reported_by)
    # Default unspecified filter is empty
    unspecified_filter = []

    if reported_by == 'self'
      include = {arrangements: :reporting_institution, profile: :arrangements}
      query = ActiveRecord::Base.send(:sanitize_sql_array, ["(arrangements.arrangement_type IN (?) AND reporting_institutions_arrangements.id = :id) OR (arrangements_profiles.arrangement_type IN (?) AND institutions.id = :id)", ['outgoing', 'domestic'], ['incoming', 'internal']])

      unspecified_arrangements_count = profile.arrangements.where(arrangement_type: 'unspecified').count if profile && profile.arrangements
      unspecified_filter = [['Unspecified or multiple', 'unspecified']] if unspecified_arrangements_count && unspecified_arrangements_count > 0
    else
      include = [{profile: {arrangements: :reported_on_institution}}, :arrangements]
      query = ActiveRecord::Base.send(:sanitize_sql_array, ["(arrangements.arrangement_type IN (?) AND reported_on_institutions_arrangements.id = :id) OR (arrangements_institutions.arrangement_type IN (?) AND institutions.id = :id)", ['incoming'], ['outgoing']])
    end

    unspecified_filter + Institution.includes(include).where(query, id: self.id)
      .order('institutions.name')
      .map { |i| [i.name, i.id] }
  end

  def arrangements_reported_by(reported_by)
    if reported_by == 'self'
      self_query = "institutions.id = ?"
    else
      self_query = "reported_on_institutions_arrangements.id = ?"
    end
    
    Arrangement
      .includes(:reporting_institution, :reported_on_institution)
      .where(self_query, self.id)
  end

  def arrangements_with_category(reported_by, role)
    if reported_by == 'self' && role == 'funder' || reported_by != 'self' && role != 'funder'
      arrangement_type = %w(outgoing internal)
    else
      arrangement_type = %w(incoming domestic)
    end

    arrangements_reported_by(reported_by)
      .includes(:action_categories)
      .where('action_categories.id IS NOT NULL')
      .where("arrangements.arrangement_type IN (?)", arrangement_type)
  end

  def arrangements_list(reported_by)
    if reported_by == 'self'
      query = "reporting_institutions.id = :id"
      query_vars = {id: self.id}
    else
      query = "reported_on_institutions.id = :id AND arrangements.arrangement_type IN (:arrangement_types)" 
      query_vars = {id: self.id, arrangement_types: %w(incoming outgoing)}
    end

    arrangements = Arrangement
      .joins(Arrangement.named_join_reporting_institution)
      .joins(Arrangement.named_join_reported_on_institution)
      .where(query, query_vars)

    # Arrangements before pagination
    arrangements_wo_pagination = arrangements.dup

    # Pagination and order by
    arrangements = arrangements.order('arrangements.title').page

    # Contribution amounts
    amounts = AnnualFinancing.where("arrangement_id IN (?)", arrangements_wo_pagination).group(:arrangement_id).sum(:contribution).values

    {
      institution_id: self.id,
      reported_by: reported_by, current_page: 1, pages: arrangements.num_pages,
      total: arrangements_wo_pagination.count, maximum: Arrangement.count,
      models: arrangements.as_json(methods: [:funder, :recipient, :total_amount]),
      timespan: {
        min: AnnualFinancing.find_all_by_arrangement_id(arrangements_wo_pagination.map(&:id)).map(&:year).min,
        max: AnnualFinancing.find_all_by_arrangement_id(arrangements_wo_pagination.map(&:id)).map(&:year).max
      },
      amount: {min: amounts.min.try(:floor), max: amounts.max.try(:ceil)},
      total_amount: amounts.sum
    }
  end

  def incoming_funding(reported_by)
    if reported_by == 'self'
      include = :reporting_institution
      arrangement_type = 'incoming'
    else
      include = :reported_on_institution
      arrangement_type = 'outgoing'
    end

    AnnualFinancing
      .includes(arrangement: include)
      .where("arrangements.arrangement_type = ?", arrangement_type)
      .where("institutions.id = ?", self)
      .sum(:contribution)
  end

  def domestic_funding
    AnnualFinancing
      .includes(arrangement: :reporting_institution)
      .where("arrangements.arrangement_type IN (?)", ['domestic', 'internal'])
      .where("institutions.id = ?", self)
      .sum(:contribution)
  end

  def outgoing_funding(reported_by)
    if reported_by == 'self'
      include = :reporting_institution
      arrangement_type = 'outgoing'
    else
      include = :reported_on_institution
      arrangement_type = 'incoming'
    end

    AnnualFinancing
      .includes(arrangement: include)
      .where("arrangements.arrangement_type = ?", arrangement_type)
      .where("institutions.id = ?", self)
      .sum(:contribution)
  end

  def unspecified_recipients_funding(reported_by)
    return 0 if reported_by == 'others'

    AnnualFinancing
      .includes(arrangement: :reporting_institution)
      .where("arrangements.arrangement_type = ?", 'unspecified')
      .where("institutions.id = ?", self)
      .sum(:contribution)
  end
  
  def funder_countries
    Institution
      .countries
      .includes(profile: {arrangements: :reported_on_institution})
      .where("arrangements.arrangement_type = ?", 'outgoing')
      .where("reported_on_institutions_arrangements.id = ?", self)
  end

  def redd_plus_countries
    Institution
      .countries
      .includes(profile: {arrangements: :reported_on_institution})
      .where("arrangements.arrangement_type = ?", 'incoming')
      .where("reported_on_institutions_arrangements.id = ?", self)
  end

  def funder_institutions
    Institution
      .includes(profile: {arrangements: :reported_on_institution})
      .where("institutions.institution_type IN (?)", %w(INTERGOVERNMENTAL_INSTITUTION INTERNATIONAL_NON_GOVERNMENTAL_INSTITUTION NATIONAL_NON_GOVERNMENTAL_INSTITUTION))
      .where("arrangements.arrangement_type IN (?)", %w(outgoing incoming))
      .where("reported_on_institutions_arrangements.id = ?", self)
  end

  def private_sector_entities
    Institution
      .includes(profile: {arrangements: :reported_on_institution})
      .where("institutions.institution_type = ?", 'PRIVATE_SECTOR_ENTITY')
      .where("arrangements.arrangement_type IN (?)", %w(outgoing incoming))
      .where("reported_on_institutions_arrangements.id = ?", self)
  end

  def funder_country?
    Institution.funder_countries.include?(self)
  end

  def redd_plus_country?
    Institution.redd_plus_countries.include?(self)
  end

  def self_has_reported
    return false unless profile
    profile.arrangements.any?
  end

  def total_arrangements
    Arrangement
      .includes(:reporting_institution, :reported_on_institution)
      .where("institutions.id = :id OR reported_on_institutions_arrangements.id = :id", {id: self})
  end

  def to_param
    "#{id_feed}"
  end

  def to_s
    acronym ? "#{acronym} - #{name}" : name
  end

  # Optionally includes indirect flows, and can be limited to only
  # funders or recipients
  # Returns self in list
  def funders_and_recipients(include_indirect = true, flow = :any)
    feed_ids = self.arrangement_totals_array(include_indirect, flow).map{|t|t[:to_id_feed]}

    Institution.where(id_feed: feed_ids).select("id_feed, name, institution_type")
  end

  def arrangement_totals_array(include_indirect = false, flow = :any)
    funding_totals = {}
    receiving_totals = {}

    perspectives = ['self', 'others']
    perspectives.each do |reported_by|
      other_parties_role = 'reported_on_institutions'
      funding = 'outgoing'
      receiving = 'incoming'
      if reported_by != 'self'
        other_parties_role = 'reporting_institutions'
        funding = 'incoming'
        receiving = 'outgoing'
      end

      # Get outgoing and incoming totals
      institution_totals_by_type = self.arrangements_reported_by(reported_by).
        joins(:annual_financings).
        select("#{other_parties_role}.id_feed, arrangement_type, sum(contribution) as total").
        group("#{other_parties_role}.id_feed, arrangement_type")

      if flow == :funders
        institution_totals_by_type = institution_totals_by_type.where(arrangement_type: receiving)
      elsif flow == :recipients
        institution_totals_by_type = institution_totals_by_type.where(arrangement_type: funding)
      else
        institution_totals_by_type = institution_totals_by_type.where(arrangement_type: [funding, receiving])
      end

      # Subtract outgoing from incoming
      institution_totals_by_type.each do |institution_total_by_type|
        if institution_total_by_type.arrangement_type == funding
          funding_totals[institution_total_by_type.id_feed] ||= 0
          funding_totals[institution_total_by_type.id_feed] += institution_total_by_type.total.to_f
        elsif institution_total_by_type.arrangement_type == receiving
          receiving_totals[institution_total_by_type.id_feed] ||= 0
          receiving_totals[institution_total_by_type.id_feed] -= institution_total_by_type.total.to_f
        end
      end
    end

    # Get the direct totals
    results = []
    [funding_totals, receiving_totals].each do |totals|
      totals.each do |id_feed, total|
        results << {from_id_feed: self.id_feed, to_id_feed: id_feed , total: total} if total != 0
      end
    end
    if flow == :any
      # Add sum total
      results << {from_id_feed: self.id_feed, to_id_feed: self.id_feed, total: -results.map{|r| r[:total]}.sum}
    end

    if include_indirect
      indirect_results = []
      # Add indirect flows
      results.each do |result|
        institution = Institution.select("id, id_feed, institution_type").where(id_feed: result[:to_id_feed]).limit(1).first
        if institution.institution_type != 'COUNTRY' 
          # ARGH Recursion (only one level deep though)
          indirect_flow = result[:total] < 0 ? :funders : :recipients
          institution.arrangement_totals_array(false, indirect_flow).each do |institution_total|
            indirect_results << institution_total
          end
        end
        results = results | indirect_results
      end
    end
    results
  end

  def arrangement_totals_by_institution(reported_by)
    other_parties_role = 'reported_on_institutions'
    funding = 'outgoing'
    receiving = 'incoming'
    if reported_by != 'self'
      other_parties_role = 'reporting_institutions'
      funding = 'incoming'
      receiving = 'outgoing'
    end

    # Get outgoing and incoming totals
    institution_totals_by_type = self.arrangements_reported_by(reported_by).
      joins(:annual_financings).
      select("#{other_parties_role}.iso2, arrangement_type, sum(contribution) as total").
      group("#{other_parties_role}.iso2, arrangement_type")

    # Subtract outgoing from incoming
    results = {}
    institution_totals_by_type.each do |institution_total_by_type|
      if institution_total_by_type.arrangement_type == funding
        results[institution_total_by_type.iso2] ||= 0
        results[institution_total_by_type.iso2] += institution_total_by_type.total.to_f
      elsif institution_total_by_type.arrangement_type == receiving
        results[institution_total_by_type.iso2] ||= 0
        results[institution_total_by_type.iso2] -= institution_total_by_type.total.to_f
      end
    end
    results
  end

  def arrangement_totals_by_year(reported_by)
    # Hash to translate perspective and arrangement type to the actual behavior from
    # the perspective of self
    action_matrix = {
      'self' => {
        'outgoing' => 'outgoing',
        'incoming' => 'incoming',
        'internal' => 'internal_domestic_unspecified',
        'domestic' => 'internal_domestic_unspecified',
        'unspecified' => 'internal_domestic_unspecified'
      },
      'others' => {
        'outgoing' => 'incoming',
        'incoming' => 'outgoing'
      }
    }

    # Get totals
    totals_by_year = self.arrangements_reported_by(reported_by).
      joins(:annual_financings).
      select("arrangement_type, year, sum(contribution) as total").
      group("arrangement_type, year").order('year')

    # Format
    if reported_by == 'self'
      results = {'categories' => ["Funding to #{self.name}", "Funding from #{self.name} (outgoing)", "Funding from #{self.name} (internal/domestic and/or outgoing funding with unspecified or multiple recipients)"], 'series' => {}}
    else
      results = {'categories' => ["Funding to #{self.name}", "Funding from #{self.name} (outgoing)"], 'series' => {}}
    end

    totals_by_year.each do |total_by_year|
      type = action_matrix[reported_by][total_by_year.arrangement_type]
      unless type.nil?
        results['series'][total_by_year.year] ||= {}
        results['series'][total_by_year.year][type] ||= 0
        results['series'][total_by_year.year][type] += total_by_year.total.to_f
      end
    end
    results
  end

  def arrangement_counts_by_action_category(reported_by)
    # Translate arrangement_types for perspective
    action_matrix = {
      'self' => {
        'incoming' => :incoming,
        'domestic' => :incoming,
        'outgoing' => :outgoing,
        'internal' => :outgoing,
        'unspecified' => :outgoing
      },
      'others' => {
        'incoming' => :outgoing,
        'outgoing' => :incoming,
      }
    }
    arrangements_reported_by(reported_by).
      joins(:action_categories).
      select('COUNT(*) as count, action_categories.name as category, arrangement_type').
      group('action_categories.name, arrangement_type').
      # Humanize names
      inject({}) do |result, category_count|
        flow = action_matrix[reported_by][category_count.arrangement_type]
        unless flow.nil?
          category = category_count.category.humanize
          result[category] ||= {incoming: 0, outgoing: 0}
          result[category][flow] += category_count.count.to_i
        end
        result
      end
  end

  def arrangements_reported_by(reported_by)
    if reported_by == 'self'
      query = "reporting_institutions.id = :id"
      query_vars = {id: self.id}
    else
      query = "reported_on_institutions.id = :id" 
      query_vars = {id: self.id}
    end

    Arrangement
      .joins(Arrangement.named_join_reporting_institution)
      .joins(Arrangement.named_join_reported_on_institution)
      .where(query, query_vars)
  end
end
