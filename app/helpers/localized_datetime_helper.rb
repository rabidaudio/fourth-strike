# frozen_string_literal: true

# Allow formatting dates and times by locale region
module LocalizedDatetimeHelper
  FORMATS = {
    'US' => {
      date: '%B %d, %Y',
      time: '%l:%M %P'
    },
    'CA' => {
      date: '%B %d, %Y',
      time: '%H:%M'
    },
    'GB' => {
      date: '%d %B %Y',
      time: '%H:%M'
    },
    'AU' => {
      date: '%d %B %Y',
      time: '%l:%M %P'
    },
    'default' => {
      date: '%F',
      time: '%H:%M'
    }
  }.freeze

  def localized_date(date, locale: I18n.locale)
    date.strftime(FORMATS[region(locale)][:date])
  end

  def localized_time(time, locale: I18n.locale)
    time.strftime(FORMATS[region(locale)][:time]).strip
  end

  def localized_datetime(time, locale: I18n.locale)
    fmt = FORMATS[region(locale)]
    time.strftime("#{fmt[:date]} #{fmt[:time]}")
  end

  private

  def region(locale)
    r = locale.to_s.to_s.split('-', 2)[1]
    return 'default' if r.blank?

    r = r.upcase
    return 'default' unless FORMATS.key?(r)

    r
  end
end
