ROOT_DIR='.'
require File.join(ROOT_DIR,'lib','riak_rolling_average')
require File.join(ROOT_DIR,'lib','data_set')

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
File.open('test/data/split_0', 'w') {|f| f.write(data.to_json) }

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
File.open('test/data/split_1', 'w') {|f| f.write(data.to_json) }

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
File.open('test/data/split_2', 'w') {|f| f.write(data.to_json) }

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
File.open('test/data/split_3', 'w') {|f| f.write(data.to_json) }

data = DataSet.generate_data_for(['randy','bryce','casey'],['dev1','dev2','dev3','dev4','dev5'],1000)
File.open('test/data/split_4', 'w') {|f| f.write(data.to_json) }
