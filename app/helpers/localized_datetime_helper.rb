# frozen_string_literal: true

# Allow formatting dates and times by locale region
module LocalizedDatetimeHelper
  FORMATS = {
    'US' => {
      date: '%B %d, %Y',
      time: '%-l:%M %P'
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
      time: '%-l:%M %P'
    },
    'default' => {
      date: '%F',
      time: '%H:%M'
    }
  }.freeze

  def localized_date(date, region: determine_region)
    date.strftime(FORMATS[region][:date])
  end

  def localized_time(time, region: determine_region)
    time.strftime(FORMATS[region][:time]).strip
  end

  def localized_datetime(time, region: determine_region)
    fmt = FORMATS[region]
    time.strftime("#{fmt[:date]} #{fmt[:time]}")
  end

  private

  def determine_region
    r = controller&.region
    # Use US if no region is defined
    return 'US' if r.nil?
    # Use default if a region other than those supported is supplied
    return 'default' unless FORMATS.key?(r)

    r
  end
end
