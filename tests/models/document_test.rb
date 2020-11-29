# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__

# Tests para users
class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase

  def test_create_document
    @doc = Document.create(
      name: 'DocPepito1',
      description: 'DescriptionEstandar1',
      fileDocument: 'PDF/Doc1.pdf',
      category_id: 1,
      date: '24/05/2020 19:18:54'
    )
    assert_equal @doc.valid?, true
  end

  def test_double_name
    @doc1 = Document.create(name: 'DocPepito1',
                            description: 'DescriptionEstandar1',
                            fileDocument: 'PDF/Doc1.pdf',
                            category_id: 1, date: '24/05/2020 19:18:54')
    @doc2 = Document.create(name: 'DocPepito1',
                            description: 'DescriptionEstandar2',
                            fileDocument: 'PDF/Doc2.pdf',
                            category_id: 1, date: '24/05/2020 19:18:54')
    assert_equal @doc1.valid?, true
    assert_equal @doc2.valid?, false
  end

  def test_double_file_document
    @doc1 = Document.create(name: 'DocPepito1',
                            description: 'DescriptionEstandar1',
                            fileDocument: 'PDF/Doc1.pdf', category_id: 1,
                            date: '24/05/2020 19:18:54')
    @doc2 = Document.create(name: 'DocPepito2',
                            description: 'DescriptionEstandar2',
                            fileDocument: 'PDF/Doc1.pdf', category_id: 1,
                            date: '24/05/2020 19:18:54')
    assert_equal @doc1.valid?, true
    assert_equal @doc2.valid?, false
  end

  def test_description_nil
    @doc = Document.create(
      name: 'DocPepito1',
      fileDocument: 'PDF/Doc1.pdf',
      category_id: 1,
      date: '24/05/2020 19:18:54'
    )
    assert_equal @doc.valid?, false
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
