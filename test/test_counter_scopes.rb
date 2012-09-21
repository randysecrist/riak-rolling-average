require File.expand_path('../helper', __FILE__)

require 'lib/data_set'

class TestCounterScopes < Test::Unit::TestCase
  def setup
    CounterDocument.destroy_all
    DataPointDocument.destroy_all

    @ds = DataSet.new
    @users = ['randy','bryce']
    @apps = ['fitbit','withings','myzeo','healthy_hospital_generator']
    @sample_size = 1000
    @type = 'storage'
    @category = 'write'
  end

  def test_daily_scope
    generate_data_for_test

    # 2)  test check counter for daily accuracy
    distribution = @ds.distribution_by_date
    period = Time.parse("#{distribution[distribution.length - 7][0]} 00:00:00 UTC")..Time.parse("#{distribution[distribution.length - 1][0]} 00:00:00 UTC")

    # 3)  assert counter == data set
    counters = CounterDocument.find(@apps.map {|app| "#{app}-#{@type}-#{@category}"})

    # data set vs counter (range flavor)
    # do 7 day range queries match?
    assert_equal @ds.sum_by_application('fitbit', period), counters[0].sum(period)
    assert_equal @ds.sum_by_application('withings', period), counters[1].sum(period)
    assert_equal @ds.sum_by_application('myzeo', period), counters[2].sum(period)
    assert_equal @ds.sum_by_application('healthy_hospital_generator', period), counters[3].sum(period)

    # monthly total accuracy
    # do all days within a month == total for that month?
  end

  def test_monthly_scope
    # data set vs counter (range flavor)
    # do monthly totals match

    # monthly total accuracy
    # do all months == totals
  end

  def test_total_scope
    generate_data_for_test

    # assert counter matches manual data set
    counters = CounterDocument.find(@apps.map {|app| "#{app}-#{@type}-#{@category}"})

    assert_equal @sample_size, counters.inject(0) {|sum,i| sum + i.count}

    assert_equal @ds.sum_by_application('fitbit'), counters[0].sum
    assert_equal @ds.sum_by_application('withings'), counters[1].sum
    assert_equal @ds.sum_by_application('myzeo'), counters[2].sum
    assert_equal @ds.sum_by_application('healthy_hospital_generator'), counters[3].sum

    assert_equal @ds.count_by_application('fitbit'), counters[0].batch_size
    assert_equal @ds.count_by_application('withings'), counters[1].batch_size
    assert_equal @ds.count_by_application('myzeo'), counters[2].batch_size
    assert_equal @ds.count_by_application('healthy_hospital_generator'), counters[3].batch_size

    assert_equal @ds.average_by_application('fitbit'), counters[0].batch_average
    assert_equal @ds.average_by_application('withings'), counters[1].batch_average
    assert_equal @ds.average_by_application('myzeo'), counters[2].batch_average
    assert_equal @ds.average_by_application('healthy_hospital_generator'), counters[3].batch_average
  end

  private

  def generate_data_for_test
    @data = @ds.generate_data_for(@users, @apps, @sample_size)
    @data.each do |triple|
      dp = DataPoint.new(
        :type => @type,
        :category => @category,
        :value => triple.data['bytes'],
        :unit => 'bytes',
        :time => triple.data['time'],
        :batch_size => triple.data['count'],
        :application => triple.application,
        :user => triple.user
      )
      DataPointDocument.create(:data_point => dp)
    end
  end

end
