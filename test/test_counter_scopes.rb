require File.expand_path('../helper', __FILE__)

require 'lib/data_set'

class TestCounterScopes < Test::Unit::TestCase
  def setup
    @ds = DataSet.new
  end

  def test_daily_scope
    # 1)  create a bunch of data points for application / user
    @data = @ds.generate_data_for(
      ['randy','bryce'],
      ['fitbit','withings','myzeo','healthy_hospital_generator'],
      500
    )

    @data.each do |triple|
      dp = DataPoint.new(
        :unit => 'bytes',
        :name => 'storage',
        :value => triple.data['bytes'],
        :time => triple.data['time'],
        :application => triple.application,
        :user => triple.user
      )
      DataPointDocument.create(:data_point => dp)
    end

    # 2)  test check counter for daily accuracy
    distribution = @ds.distribution_by_date
    range = Time.parse(distribution[distribution.length - 7][0])..Time.parse(distribution[distribution.length - 1][0])

    # 3)  assert counter == data set
  end

  def test_monthly_scope
  end

  def test_total_scope
  end

end
