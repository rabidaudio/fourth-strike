# frozen_string_literal: true

class ReplaceSigfigsWithTrueSplits < ActiveRecord::Migration[7.2]
  def up
    sig_figs = Payee.find_by!(fsn: 'FS-175')

    splits = Rails.application.config.app_config[:sig_figs][:splits].map do |payee_info, percentage|
      _, fsn = HomeSheetReport.parse_payee(payee_info)
      payee = Payee.find_by!(fsn: fsn)
      integer_split = ((percentage / 100.0) * 10_000.0).round
      [payee, integer_split]
    end

    products = sig_figs.splits.map(&:product).uniq

    CalculatorCache::Manager.defer_recompute do
      products.each do |product|
        unless product.splits.where.not(payee: sig_figs).empty?
          raise StandardError, 'SigFig splits are shared with other payees'
        end

        product.splits.delete_all

        splits.each do |payee, integer_split|
          Split.create!(product: product, payee: payee, value: integer_split)
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
