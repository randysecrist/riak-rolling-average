require File.expand_path('../helper', __FILE__)

require 'lib/data_set'

class DataSetTest < Test::Unit::TestCase
  def setup
    @ds = DataSet.new
  	@multi_data = @ds.generate_data_for(
      ['randy','bryce'],
      ['fitbit','withings','myzeo','mapmyfitness'],
      1000
    )
  end

  def test_serialization
    b_sum = @ds.sum
    b_count = @ds.count
    b_avg = @ds.average

    #File.open('/Users/randy/test.txt', 'w') {|f| f.write(@multi_data.to_json) }
    #input = JSON.parse(File.read(File.join('/Users/randy','test.txt')))

    # serialize
    serialized = ''
    StringIO.open(serialized) {|f| f.write(@multi_data.to_json) }

    # deserialize
    input = JSON.parse(StringIO.new(serialized).read)

    new_ds = DataSet.deserialize(input)
    a_sum = new_ds.sum
    a_count = new_ds.count
    a_avg = new_ds.average

    assert_equal b_sum, a_sum
    assert_equal b_count, a_count
    assert_equal b_avg, a_avg
  end

  def test_multi_app
    fitbit_bytes = @ds.sum_by_application('fitbit')
    withings_bytes = @ds.sum_by_application('withings')
    myzeo_bytes = @ds.sum_by_application('myzeo')
    mmf_bytes = @ds.sum_by_application('mapmyfitness')
    assert_equal @ds.sum, (fitbit_bytes + withings_bytes + myzeo_bytes + mmf_bytes)
  end

  def test_multi_user
    randy_bytes = @ds.sum_by_user('randy')
    bryce_bytes = @ds.sum_by_user('bryce')
    assert_equal @ds.sum, (randy_bytes + bryce_bytes)
  end

  def test_multi_app_by_period
    # get the last 7 days or so
    distribution = @ds.distribution_by_date
    unless distribution.length < 7
      range = Time.parse(distribution[distribution.length - 7][0])..Time.parse(distribution[distribution.length - 1][0])
      range_sum = @ds.data.select {|i| range.cover?(i.data['time'])}.inject(0) {|sum,j| sum + j.data['bytes']}
      assert_equal range_sum, @ds.sum_by_period(range)

      fitbit_bytes = @ds.sum_by_application('fitbit', range)
      withings_bytes = @ds.sum_by_application('withings', range)
      myzeo_bytes = @ds.sum_by_application('myzeo', range)
      mmf_bytes = @ds.sum_by_application('mapmyfitness', range)

      assert_equal range_sum, (fitbit_bytes + withings_bytes + myzeo_bytes + mmf_bytes)
    end
  end

end
