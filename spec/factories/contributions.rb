# frozen_string_literal: true

# == Schema Information
#
# Table name: contributions
#
#  id            :integer          not null, primary key
#  details       :text
#  is_songwriter :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  artist_id     :integer          not null
#  track_id      :integer          not null
#
# Indexes
#
#  index_contributions_on_artist_id  (artist_id)
#  index_contributions_on_track_id   (track_id)
#
# Foreign Keys
#
#  artist_id  (artist_id => artists.id)
#  track_id   (track_id => tracks.id)
#
FactoryBot.define do
  factory :contribution do
    track
    artist
    is_songwriter { false }
    details do
      if is_songwriter
        'written by'
      else
        [
          'vocals', 'guitar', 'bass', 'keys', 'drums', 'production'
        ].sample(Faker::Number.between(from: 1, to: 2)).join(', ')
      end
    end
  end
end
