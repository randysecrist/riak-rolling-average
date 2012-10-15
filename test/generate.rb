ROOT_DIR='.'
require File.join(ROOT_DIR,'lib','riak_rolling_average')
require File.join(ROOT_DIR,'lib','data_set')

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
ds = DataSet.new(data)
File.open('test/data/split_0', 'w') {|f| f.write(data.to_json) }
puts "Batch Count: #{ds.count}, Avg: #{ds.average}, Sum: #{ds.sum}, Length: #{data.length}"

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
ds = DataSet.new(data)
File.open('test/data/split_1', 'w') {|f| f.write(data.to_json) }
puts "Batch Count: #{ds.count}, Avg: #{ds.average}, Sum: #{ds.sum}, Length: #{data.length}"

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
ds = DataSet.new(data)
File.open('test/data/split_2', 'w') {|f| f.write(data.to_json) }
puts "Batch Count: #{ds.count}, Avg: #{ds.average}, Sum: #{ds.sum}, Length: #{data.length}"

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
ds = DataSet.new(data)
File.open('test/data/split_3', 'w') {|f| f.write(data.to_json) }
puts "Batch Count: #{ds.count}, Avg: #{ds.average}, Sum: #{ds.sum}, Length: #{data.length}"

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
ds = DataSet.new(data)
File.open('test/data/split_4', 'w') {|f| f.write(data.to_json) }
puts "Batch Count: #{ds.count}, Avg: #{ds.average}, Sum: #{ds.sum}, Length: #{data.length}"
