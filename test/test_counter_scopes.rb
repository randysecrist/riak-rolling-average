require File.expand_path('../helper', __FILE__)

require 'lib/data_set'

class TestCounterScopes < Test::Unit::TestCase
  def setup
    @ds = DataSet.new
    @users = ['randy','bryce']
    @apps = ['fitbit','withings','myzeo','healthy_hospital_generator']
    @sample_size = 500
  end

  def test_daily_scope
    # 1)  create a bunch of data points for application / user
    @data = @ds.generate_data_for(@users, @apps, @sample_size)

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
    counters = CounterDocument.find(@apps)

    assert_equal @sample_size, counters.inject(0) {|sum,i| sum + i.count}

    assert_equal @ds.sum_by_application('fitbit'), counters[0].sum
    assert_equal @ds.sum_by_application('withings'), counters[1].sum
    assert_equal @ds.sum_by_application('myzeo'), counters[2].sum
    assert_equal @ds.sum_by_application('healthy_hospital_generator'), counters[3].sum

    #assert_equal @ds.count_by_application('fitbit'), counters[0].count
    #assert_equal @ds.count_by_application('withings'), counters[1].count
    #assert_equal @ds.count_by_application('myzeo'), counters[2].count
    #assert_equal @ds.count_by_application('healthy_hospital_generator'), counters[3].count

    #assert_equal @ds.average_by_application('fitbit'), counters[0].average
    #assert_equal @ds.average_by_application('withings'), counters[1].average
    #assert_equal @ds.average_by_application('myzeo'), counters[2].average
    #assert_equal @ds.average_application('healthy_hospital_generator'), counters[3].average
  end

  def test_monthly_scope
  end

  def test_total_scope
  end

end
