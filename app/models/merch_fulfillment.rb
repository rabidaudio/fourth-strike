# frozen_string_literal: true

# == Schema Information
#
# Table name: merch_fulfillments
#
#  id                       :integer          not null, primary key
#  production_cost_cents    :integer          default(0), not null
#  production_cost_currency :string           default("USD"), not null
#  shipped_on               :date
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  bandcamp_sale_id         :integer
#  fulfilled_by_id          :integer
#
# Indexes
#
#  index_merch_fulfillments_on_bandcamp_sale_id  (bandcamp_sale_id)
#  index_merch_fulfillments_on_fulfilled_by_id   (fulfilled_by_id)
#
# Foreign Keys
#
#  bandcamp_sale_id  (bandcamp_sale_id => bandcamp_sales.id)
#  fulfilled_by_id   (fulfilled_by_id => admins.id)
#

# This record is created when a merch item is shipped. It records
# the cost of the product, so we can deduct it before calculating
# royalty costs.
# Royalties are not attributed until a merch item is fulfilled.
# Production cost is the cost of the item. It does not including shipping,
# bandcamp fees, or transaction fees; only the cost of the product.
# fulfilled_by_id is a pointer to the Admin who marked the product as shipped.
class MerchFulfillment < ApplicationRecord
  include MonitizedSum

  belongs_to :bandcamp_sale, optional: true
  # fulfilled by will be nil for internal merch orders
  belongs_to :fulfilled_by, class_name: 'Admin', optional: true

  monetize :production_cost_cents

  validates :production_cost_currency, inclusion: { in: Money.default_currency.iso_code }
end
