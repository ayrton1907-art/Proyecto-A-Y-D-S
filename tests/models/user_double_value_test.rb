# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__

# Tests para users
class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase

  def test_double_username
    @user1  = User.create(name: 'Pepito1', surname: 'Clavito1',
                          dni: 12_345_678, username: 'Clavo02',
                          password: '112358', email: 'pablito1@gmail.com',
                          rol: 0, admin: 0)
    @user2  = User.create(name: 'Pepito2', surname: 'Clavito2',
                          dni: 12_345_679, username: 'Clavo02',
                          password: '1123581', email: 'pablito2@gmail.com',
                          rol: 0, admin: 0)
    assert_equal @user1.valid?, true
    assert_equal @user2.valid?, false
  end

  def test_double_dni
    @user1  = User.create(name: 'Pepito', surname: 'Clavito',
                          dni: 12_345_678, username: 'Clavo02',
                          password: '112358', email: 'pablito1@gmail.com',
                          rol: 0, admin: 0)
    @user2  = User.create(name: 'Pepito', surname: 'Clavito',
                          dni: 12_345_678, username: 'Clavo02',
                          password: '1123581', email: 'pablito2@gmail.com',
                          rol: 0, admin: 0)
    assert_equal @user1.valid?, true
    assert_equal @user2.valid?, false
  end

  def test_double_email
    @user1  = User.create(name: 'Pepito', surname: 'Clavito',
                          dni: 12_345_678, username: 'Clavo02',
                          password: '112358', email: 'pablito2@gmail.com',
                          rol: 0, admin: 0)
    @user2  = User.create(name: 'Pepito', surname: 'Clavito',
                          dni: 12_345_678, username: 'Clavo02',
                          password: '1123581', email: 'pablito2@gmail.com',
                          rol: 0, admin: 0)
    assert_equal @user1.valid?, true
    assert_equal @user2.valid?, false
  end
end
