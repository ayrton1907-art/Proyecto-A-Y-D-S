# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra-websocket'
require './models/init'

# Service para categorias
class CategoryService
  def self.crear_categoria(nombre, descripcion)
    return raise ArgumentError, 'Ya existe una categoria con ese nombre' unless Category.find(name: nombre) == nil

    @category = Category.new(name: nombre, description: descripcion)
    return raise ArgumentError, 'La categoria no fue creada' unless @category.save
  end

  def self.modificar_categoria(nombre, description, id)
    @old_cat = Category.find(id: id)
    return raise ArgumentError, 'Categoria no encontrada' unless @old_cat != nil

    @cat_modify = @old_cat
    @cat_modify.update(name: nombre,
                       description: description)
    return raise ArgeumentError, 'La categoria no fue modificada' unless @old_cat.name != @cat_modify ||
                                                                         @old_cat.description != @cat_modify.description
  end

  def self.eliminar_categoria(id_cat_eliminar, id_nueva_categoria)
    @category_delete = Category.find(id: id_cat_eliminar)
    @category_selected = Category.find(id: id_nueva_categoria)
    raise ArgeumentError, 'No se encontro la categoria a eliminar' unless @category_delete
    raise ArgumentError, 'No se encontro la categoria para migrar' unless @category_selected

    @document = Document.where(category_id: @category_delete.id)
    migrar(@document, @category_selected)

    @all_docs = Document.where(category_id: @category_delete.id)
    return unless @all_docs.empty?

    @category_delete.remove_all_users
    @category_delete.delete
  end

  def self.migrar(documentos, nueva_cat)
    documentos.each do |element|
      element.update(category_id: nueva_cat.id)
    end
  end
end
