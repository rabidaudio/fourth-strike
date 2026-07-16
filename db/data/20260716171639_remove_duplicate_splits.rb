# frozen_string_literal: true

class RemoveDuplicateSplits < ActiveRecord::Migration[8.0]
  def up
    dups = Split.group(:product_type, :product_id, :payee_id).count
                .select { |_, v| v > 1 }
                .map { |(t, id, _), _| t.constantize.find(id) }
                .uniq
    dups.each do |product|
      unless product.splits.all? { |s| s.value == 1 }
        raise StandardError,
              "Unable to fix #{product.class.name} #{product.id} automatically. Please fix by hand and try again"
      end

      product.splits.group(:payee_id).count.each do |payee_id, count|
        next unless count > 1

        Split.where(product: product, payee_id: payee_id).delete_all
        Split.create!(product: product, payee_id: payee_id, value: 1)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
