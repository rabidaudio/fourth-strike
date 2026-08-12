# frozen_string_literal: true

# Converting ruby data structs into Vue props can be verbose. This
# helper encapsulates that logic.
module PropsHelper
  def track_contributors_props(track)
    props = { track_id: track.id }
    props[:contributions] = track.contributions.order(level: :desc).map do |contribution|
      contribution.slice(:details, :level).merge(payee: {
                                                   fsn: contribution.artist&.payee&.fsn,
                                                   name: contribution.artist&.payee&.name
                                                 })
    end
    props.to_json
  end

  def edit_splits_props(splits, **opts)
    split_props = (splits || []).map do |s|
      {
        payee: { name: s.payee.name, fsn: s.payee.fsn },
        value: s.value
      }
    end
    { splits: split_props }.merge(opts).to_json
  end
end
