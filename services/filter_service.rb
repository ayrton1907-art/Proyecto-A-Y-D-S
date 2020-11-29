# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Service para los filtros de busqueda de lo documentos
class FilterService
  def self.filter(document_id, filter, category_id, date_filter)
    @all_documents = Document.order(:name).all
    @all_documents = if document_id
                       Document.where(id: document_id).all
                     else
                       filter_advanced(@all_documents, filter, category_id, date_filter)
                     end
    @all_documents
  end

  def self.filter_advanced(_all_documents, filter, category_id, date_filter)
    if filter
      filter_order(@all_documents, filter, category_id, date_filter)
    elsif category_id
      filter_category(@all_documents, category_id, date_filter)
    elsif date_filter != ''
      filter_date(@all_documents, date_filter)
    else
      @all_documents
    end
  end

  def self.filter_order(documents, filter, category_id, date_filter)
    @all_documents_order = order_document(documents, filter)
    if category_id
      filter_category(@all_documents_order, category_id, date_filter)
    elsif date_filter != ''
      filter_date(@all_documents_order, date_filter)
    else
      @all_documents_order
    end
  end

  def self.filter_category(oder_document, category_id, date_filter)
    @documents_category = Document.where(category_id: category_id).all
    @documents = []
    oder_document&.each do |element|
      @documents << element if @documents_category.include?(element)
    end
    if date_filter != ''
      filter_date(@documents, date_filter)
    else
      @documents
    end
  end

  def self.filter_date(all_documents, date)
    return unless date != ''

    new_date = new_date(date)
    @document_date = Document.where(date: new_date[0..-3]).all
    @documents = document_order(all_documents)
    @documents
  end

  def self.new_date(date)
    new_date = ''
    month_num = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    month = %w[Jan Feb Apr May Jun Jul Aug Sep Oct Nov Dec]
    month_num.each do |element|
      new_date = "#{date[8, 12]}-11-#{date[4, 4]}" if date[0, 3] == month[element]
    end
    new_date
  end

  def self.document_order(all_documents)
    @documents = []
    all_documents&.each do |element|
      @documents << element if @document_date.include?(element)
    end
    @documents
  end

  def self.order_document(documents, filter)
    if filter == 'date0'
      Document.reverse_order(:date).all
    else
      documents
    end
  end
end
