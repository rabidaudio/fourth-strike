# frozen_string_literal: true

# Converting ruby data structs into Vue props can be verbose. This
# helper encapsulates that logic.
module PropsHelper
  def track_contributors_props(track)
    props = { track_id: track.id }
    props[:contributions] = track.contributions.map do |contribution|
      contribution.slice(:details, :is_songwriter).merge(artist: {
                                                           name: contribution.artist.name,
                                                           id: contribution.artist.id
                                                         })
    end
    props.to_json
  end

  def edit_splits_props(splits)
    {
      splits: splits.map { |s| { payee: { name: s.payee.name, fsn: s.payee.fsn }, value: s.value } }
    }.to_json
  end
end
