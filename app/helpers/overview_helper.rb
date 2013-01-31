module OverviewHelper
  def diagram_amount_format(amount)
    "$%.2f B" % (amount / 1_000)
  end
end
