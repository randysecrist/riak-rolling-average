require 'ripple'

class DataPointDocument
  include Ripple::Document

  one :data_point, :class_name => 'DataPoint', :presence => true

  after_save :update_statistics

  def update_statistics
    id = "#{self.data_point.application}-#{self.data_point.type}-#{self.data_point.category}"
    counter = CounterDocument.find(id) || CounterDocument.new
    counter.key = id
    counter.update_with self.data_point
  end
end
