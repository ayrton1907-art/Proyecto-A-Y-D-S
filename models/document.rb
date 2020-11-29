# frozen_string_literal: true

# Modelo de Document
class Document < Sequel::Model
  many_to_one :categories
  many_to_many :users
  one_to_one :notification
  plugin :validation_helpers
  def validate
    super
    validates_presence %i[name description date fileDocument]
    validates_length_range 10..100, :name
    validates_length_range 10..1000, :description
    validates_type String, %i[name description fileDocument]
    validates_type String, :date
    validates_unique(:name)
  end
end
