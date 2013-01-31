class Arrangement < ActiveRecord::Base
  # Associations
  belongs_to :profile
  has_one :reporting_institution, through: :profile, source: :institution

  belongs_to :reported_on_institution, class_name: 'Institution', foreign_key: :institution_id

  has_many :annual_financings
  has_many :action_categories, dependent: :destroy
  has_many :phases, dependent: :destroy

  has_and_belongs_to_many :beneficiary_countries, class_name: 'Institution', join_table: 'beneficiary_countries', uniq: true

  # Validations
  #validates :arrangement_type, inclusion: { in: %w(incoming outgoing domestic internal unspecified), allow_nil: true }

  # Scopes
  scope :funding, where("arrangement_type IN (?) OR arrangement_type IS NULL", %w(outgoing internal))
  scope :receiving, where(:arrangement_type => %w(incoming domestic))

  class << self
    # Overview page method to return number of all the arrangements
    def overview_redd_plus_arrangements
      count
    end

    def overview_list(reported_by)
      if reported_by == 'funders'
        arrangements = where("arrangement_type IN (?)", %w(outgoing domestic internal unspecified))
      else
        arrangements = where("arrangement_type IN (?)", %w(incoming domestic internal))
      end

      # Arrangements before pagination
      arrangements_wo_pagination = arrangements.dup

      # Pagination and order by
      arrangements = arrangements.order('arrangements.title').page

      # Contribution amounts
      amounts = AnnualFinancing.where("arrangement_id IN (?)", arrangements_wo_pagination).group(:arrangement_id).sum(:contribution).values

      {
        :reported_by => reported_by, :current_page => 1, :pages => arrangements.num_pages,
        :total => arrangements_wo_pagination.count, :maximum => count,
        :models => arrangements.as_json(methods: [:funder, :recipient, :total_amount]),
        :timespan => {:min => AnnualFinancing.minimum(:year), :max => AnnualFinancing.maximum(:year)},
        :amount => {:min => amounts.min, :max => amounts.max.try(:ceil)},
        :total_amount => amounts.sum
      }
    end

    def search(options)
      arrangements = includes(:reporting_institution, :reported_on_institution, :annual_financings)

      if options[:reported_by] == 'funders'
        arrangements = arrangements.where("arrangement_type IN (?)", %w(outgoing internal domestic unspecified))
        # Funder and recipient
        arrangements = arrangements.where("institutions.id = ?", options[:funder]) if options[:funder]

        if options[:recipient] && options[:recipient] == 'unspecified'
          arrangements = arrangements.where(arrangement_type: 'unspecified')
        elsif options[:recipient]
          arrangements = arrangements.where("reported_on_institutions_arrangements.id = ?", options[:recipient])
        end
      elsif options[:reported_by] == 'recipients'
        arrangements = arrangements.where("arrangement_type IN (?)", %w(incoming domestic internal))
        # Funder and recipient
        arrangements = arrangements.where("reported_on_institutions_arrangements.id = ?", options[:funder]) if options[:funder]
        arrangements = arrangements.where("institutions.id = ?", options[:recipient]) if options[:recipient]
      elsif options[:reported_by] == 'self'
        arrangements = arrangements.where("institutions.id = ?", options[:institution_id])
        # Funder and recipient
        if options[:recipient] && options[:recipient] == 'unspecified'
          arrangements = arrangements.where("reported_on_institutions_arrangements.id = ?", options[:funder]) if options[:funder]
        else
          arrangements = arrangements.where("(arrangement_type = ? AND reported_on_institutions_arrangements.id = ?) OR (arrangement_type IN (?) AND institutions.id = ?)", 'incoming', options[:funder], ['outgoing', 'internal', 'domestic'], options[:funder]) if options[:funder]
        end

        if options[:recipient] && options[:recipient] == 'unspecified'
          arrangements = arrangements.where(arrangement_type: 'unspecified')
        elsif options[:recipient]
          arrangements = arrangements.where("(arrangement_type = ? AND reported_on_institutions_arrangements.id = ?) OR (arrangement_type IN (?) AND institutions.id = ?)", 'outgoing', options[:recipient], ['incoming', 'internal', 'domestic'], options[:recipient])
        end
      elsif options[:reported_by] == 'others'
        arrangements = arrangements.where("arrangement_type IN (?)", %w(incoming outgoing))
        arrangements = arrangements.where("reported_on_institutions_arrangements.id = ?", options[:institution_id])
        # Funder and recipient
        arrangements = arrangements.where("(arrangement_type = ? AND institutions.id = ?) OR (arrangement_type = ? AND reported_on_institutions_arrangements.id = ?)", 'outgoing', options[:funder], 'incoming', options[:funder]) if options[:funder]
        arrangements = arrangements.where("(arrangement_type = ? AND institutions.id = ?) OR (arrangement_type = ? AND reported_on_institutions_arrangements.id = ?)", 'incoming', options[:recipient], 'outgoing', options[:recipient]) if options[:recipient]
      end

      # Period
      arrangements = arrangements.where(["period_to >= ?", options[:period_from]]) if options[:period_from]
      arrangements = arrangements.where(["period_from <= ?", options[:period_to]]) if options[:period_to]

      # Amount
      arrangements = arrangements.joins(sanitize_sql_array(["INNER JOIN (SELECT a.id FROM arrangements a LEFT OUTER JOIN annual_financings ON arrangement_id = a.id GROUP BY a.id HAVING SUM(contribution) >= ?) JOIN_AMOUNT_FROM ON arrangements.id = JOIN_AMOUNT_FROM.id", options[:amount_from]])) if options[:amount_from]
      arrangements = arrangements.joins(sanitize_sql_array(["INNER JOIN (SELECT a.id FROM arrangements a LEFT OUTER JOIN annual_financings ON arrangement_id = a.id GROUP BY a.id HAVING SUM(contribution) <= ?) JOIN_AMOUNT_TO ON arrangements.id = JOIN_AMOUNT_TO.id", options[:amount_to]])) if options[:amount_to]

      # Arrangements before pagination
      arrangements_wo_pagination = arrangements.dup

      # Pagination and order by
      arrangements = arrangements.order('arrangements.title').page(options[:page])

      {
        institution_id: options[:institution_id],
        reported_by: options[:reported_by], current_page: options[:page], pages: arrangements.num_pages,
        total: arrangements_wo_pagination.count, maximum: count,
        models: arrangements.as_json(methods: [:funder, :recipient, :total_amount]),
        total_amount: AnnualFinancing.where("arrangement_id IN (?)", arrangements_wo_pagination).sum(:contribution)
      }
    end

    def counts_by_action_category(reported_by)
      (reported_by == 'funders' ? funding : receiving).
        joins(:action_categories).
        count(group: 'action_categories.name').
        # Humanize names
        inject({}) { |result, element| result[element[0].humanize] = element[1]; result }
    end

    # Returns a string to join the reporting_institution as 'reporting_institutions', rather than allowing AR
    # to assign the join a name. Makes it easier to reference the join in conditions
    def named_join_reporting_institution
      <<SQL
        INNER JOIN profiles ON profiles.id = arrangements.profile_id
        INNER JOIN institutions reporting_institutions ON reporting_institutions.id = profiles.institution_id
SQL
    end

    # Returns a string to join the reported_on_institutions as 'reported_on_institutions', rather than allowing AR
    # to assign the join a name. Makes it easier to reference the join in conditions
    def named_join_reported_on_institution
      "INNER JOIN institutions reported_on_institutions ON reported_on_institutions.id = arrangements.institution_id"
    end
  end

  def funder
    if %w(outgoing internal).include?(arrangement_type)
      reporting_institution
    else
      reported_on_institution
    end
  end

  def recipient
    if %w(incoming domestic).include?(arrangement_type)
      reporting_institution
    else
      reported_on_institution
    end
  end

  def total_amount
    annual_financings.sum(:contribution)
  end

  def total_disbursement
    annual_financings.sum(:disbursement)
  end

  def to_param
    "#{id_feed}"
  end

  def title
    self[:title] == 'null' || self[:title].blank? ? 'Untitled' : self[:title]
  end

  def to_s
    title
  end

  def humanize_last_published_update
    last_published_update.gmtime.strftime("%d-%B-%Y %H:%M GMT")
  end

  def beneficiary_regions
    beneficiary_countries.map(&:region).compact.uniq
  end

  def years
    return [] if annual_financings.empty?
    (annual_financings.minimum('year')..annual_financings.maximum('year')).to_a
  end

  def contribution_for_year(year)
    annual_financings.find_by_year(year).try(:contribution) || 0
  end

  def disbursement_for_year(year)
    value = annual_financings.find_by_year(year).try(:disbursement)
    value.nil? ? '' : sprintf("%#1.2f", value)
  end

  # Kaminari pagination
  paginates_per 20

  def similar_arrangements
    return [] if reported_on_institution.nil? || reporting_institution.nil?
    institutions_ids = [reported_on_institution.id, reporting_institution.id]
    Arrangement.includes(:reporting_institution, :reported_on_institution, :annual_financings).where(["arrangements.id != :id AND arrangements.arrangement_type IN (:arrangement_types) AND institutions.id IN (:institutions) AND reported_on_institutions_arrangements.id IN (:institutions)", id: self.id, arrangement_types: %w(incoming outgoing), institutions: institutions_ids]).order('reported_on_institutions_arrangements.name, year')
  end
end
