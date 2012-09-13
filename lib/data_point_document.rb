require 'ripple'

class DataPointDocument
  include Ripple::Document

  one :data_point, :class_name => 'DataPoint', :presence => true

  after_save :update_statistics

  def update_statistics
    id = 'data_point_document_statistic'
    counter = CounterDocument.find(id) || CounterDocument.new
    counter.key = id
    counter.update_with self.data_point
  end
end
