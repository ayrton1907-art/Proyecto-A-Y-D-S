# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__

# Tests para users
class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase

  def test_create_category
    @cat = Category.create(name: 'Cat1', description: 'DescriptionEstandar1')
    assert_equal @cat.valid?, true
  end

  def test_double_name
    @cat1  = Document.create(name: 'Cat1', description: 'DescriptionEstandar1')
    @cat2  = Document.create(name: 'Cat1', description: 'DescriptionEstandar2')
    assert_equal @cat1.valid?, true
    assert_equal @cat2.valid?, false
  end

  def test_double_description
    @cat1  = Document.create(name: 'Cat1', description: 'DescriptionEstandar1')
    @cat2  = Document.create(name: 'Cat2', description: 'DescriptionEstandar1')
    assert_equal @doc1.valid?, true
    assert_equal @doc2.valid?, false
  end

  def test_name_nil
    @cat = Category.create(description: 'DescriptionEstandar1')
    assert_equal @cat.valid?, false
  end

  def test_description_nil
    @cat = Category.create(name: 'Cat1')
    assert_equal @cat.valid?, false
  end

  def test_file_document_nil
    @doc = Document.create(
      name: 'DocPepito1',
      description: 'DescriptionEstandar1',
      category_id: 1,
      date: '24/05/2020 19:18:54'
    )
    assert_equal @doc.valid?, false
  end

  def test_category_nil
    @doc = Document.create(
      name: 'DocPepito1',
      description: 'DescriptionEstandar1',
      fileDocument: 'PDF/Doc1.pdf',
      date: '24/05/2020 19:18:54'
    )
    assert_equal @doc.valid?, false
  end
end
