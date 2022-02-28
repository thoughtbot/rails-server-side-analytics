class Event < ApplicationRecord
  serialize :params
  belongs_to :visitor
end
