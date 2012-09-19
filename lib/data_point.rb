require 'ripple'

class DataPoint
  include Ripple::EmbeddedDocument
  embedded_in 'DataPointDocument'

  # --- PROPERTIES ---

  # the name of the metric
  property :name, String

  # the value of the metric
  property :value, Integer, :presence => true

  # the unit of the metric
  property :unit, String

  # the time the metric was recorded
  property :time, Time

  # the owning application of the metric
  property :application, String

  # the owning user of the metric
  property :user, String

  # the source of the metric
  property :source, String

  # --- END PROPERTIES ---

  # --- INDEX DEFS ---

  index :application, String do
  	"#{self.application}"
  end

  index :time, String do
  	"#{self.time.iso8601(6)}"
  end

  index :application_time, String do
  	"#{self.application}-#{self.time.iso8601(6)}"
  end

  index :user, String do
    "#{self.user}"
  end

  index :user_time, String do
    "#{self.user}-#{self.time.iso8601(6)}"
  end

  index :application_user, String do
    "#{self.application}-#{self.user}"
  end

  index :application_user_time, String do
    "#{self.application}-#{self.user}-#{self.time.iso8601(6)}"
  end

  # --- END INDEX DEFS ---

end
