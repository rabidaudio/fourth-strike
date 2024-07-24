# frozen_string_literal: true

# == Schema Information
#
# Table name: patreon_sales
#
#  id                          :integer          not null, primary key
#  customer_name_hashed        :string           not null
#  net_revenue_amount_cents    :integer          default(0), not null
#  net_revenue_amount_currency :string           default("USD"), not null
#  period                      :date             not null
#  product_type                :string           not null
#  tier                        :string           not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  product_id                  :integer          not null
#
# Indexes
#
#  idx_on_customer_name_hashed_period_product_type_pro_57f480592f  (customer_name_hashed,period,product_type,product_id) UNIQUE
#  index_patreon_sales_on_product                                  (product_type,product_id)
#

# For a while, we ran a Patreon. Some of patreon revenue was distributed
# as either digital album sales or merch sales. See home_sheet:load_patreon
# rake task for details.
# `customer_name_hashed` is an MD5 digest of the customer's name, used for uniqueness purposes while obfuscating PII.
# `net_revenue_amount` is the value of the pledge amount after patreon cut and processing fees, as distributed amongst
# all the items for that month.
# `period` is the first of the month for which the pledge was made
# `tier` is the name of the patreon tier at which the customer was subscribed
class PatreonSale < ApplicationRecord
  include Sale

  monetize :net_revenue_amount_cents

  validates :tier, inclusion: { in: Rails.application.config.app_config[:patreon][:tiers].keys }
  validate :ensure_period_is_first_of_month

  private

  def ensure_period_is_first_of_month
    errors.add(:period, 'must be the first of the month') unless period == period.at_beginning_of_month
  end
end
