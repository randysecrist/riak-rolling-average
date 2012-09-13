require 'ripple'

Ripple.load_config(File.join(ROOT_DIR,'config','ripple.yml'), ['test'])

# load Ripple models
require File.join(ROOT_DIR,'lib','counter_document')
require File.join(ROOT_DIR,'lib','data_point')
require File.join(ROOT_DIR,'lib','data_point_document')
require File.join(ROOT_DIR,'lib','client')
