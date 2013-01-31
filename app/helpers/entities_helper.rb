module EntitiesHelper
  def reported_by_humanize
    @reported_by == 'self' ? @institution : 'Others'
  end

  def funding_amount_format(amount)
    raw "$%.2f <small>m</small>" % amount
  end
end
