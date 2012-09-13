require File.expand_path('../helper', __FILE__)

require 'lib/data_set'

class TimeUtilsTest < Test::Unit::TestCase
  def setup
    @ds = DataSet.new
  end

  def test_daily_resolution
    # 1)  create a bunch of data points for application / user
    @data = @ds.generate_data_for(
      ['randy','bryce'],
      ['fitbit','withings','myzeo','healthy_hospital_generator'],
      500
    )

    # 2)  test check counter for daily accuracy
    distribution = @ds.distribution_by_date
    range = Time.parse(distribution[distribution.length - 7][0])..Time.parse(distribution[distribution.length - 1][0])

    # 3)  assert counter == data set
  end

  def test_monthly_resolution
  end

  def test_total_resolution
  end

end
