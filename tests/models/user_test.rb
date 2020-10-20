# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__
class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase

  def test_create_user
    @user = User.create(
      name: 'Pepito',
      surname: 'Clavito',
      dni: 12_345_678,
      username: 'Clavo02',
      password: '112358',
      email: 'pablito@gmail.com',
      rol: 0,
      admin: 0
    )
    assert_equal @user.valid?, true
  end

  def test_name_nil
    @user = User.create(
      surname: 'Clavito',
      dni: 12_345_678,
      username: 'Clavo02',
      password: '112358',
      email: 'pablito@gmail.com',
      rol: 0,
      admin: 0
    )
    assert_equal @user.valid?, false
  end

  def test_surname_nil
    @user = User.create(
      name: 'Pepito',
      dni: 12_345_678,
      username: 'Clavo02',
      password: '112358',
      email: 'pablito@gmail.com',
      rol: 0,
      admin: 0
    )
    assert_equal @user.valid?, false
  end

  def test_dni_nil
    @user = User.create(
      name: 'Pepito',
      surname: 'Clavito',
      username: 'Clavo02',
      password: '112358',
      email: 'pablito@gmail.com',
      rol: 0,
      admin: 0
    )
    assert_equal @user.valid?, false
  end

  def test_username_nil
    @user = User.create(
      name: 'Pepito',
      surname: 'Clavito',
      dni: 12_345_678,
      password: '112358',
      email: 'pablito@gmail.com',
      rol: 0,
      admin: 0
    )
    assert_equal @user.valid?, false
  end

  def test_password_user
    @user = User.create(
      name: 'Pepito',
      surname: 'Clavito',
      dni: 12_345_678,
      username: 'Clavo02',
      email: 'pablito@gmail.com',
      rol: 0,
      admin: 0
    )
    assert_equal @user.valid?, false
  end

  def test_email_nil
    @user = User.create(
      name: 'Pepito', surname: 'Clavito',
      dni: 12_345_678, username: 'Clavo02',
      password: '112358', rol: 0,
      admin: 0
    )
    assert_equal @user.valid?, false
  end

  def test_rol_nil
    @user = User.create(
      name: 'Pepito', surname: 'Clavito',
      dni: 12_345_678, username: 'Clavo02',
      password: '112358', email: 'pablito@gmail.com',
      admin: 0
    )
    assert_equal @user.valid?, false
  end

  def test_admin_nil
    @user = User.create(
      name: 'Pepito', surname: 'Clavito',
      dni: 12_345_678, username: 'Clavo02',
      password: '112358', email: 'pablito@gmail.com',
      rol: 0
    )
    assert_equal @user.valid?, false
  end

  def test_double_username
    @user1  = User.create(
      name: 'Pepito1', surname: 'Clavito1',
      dni: 12_345_678, username: 'Clavo02',
      password: '112358', email: 'pablito1@gmail.com',
      rol: 0,
      admin: 0
    )
    @user2  = User.create(
      name: 'Pepito2', surname: 'Clavito2',
      dni: 12_345_679, username: 'Clavo02',
      password: '1123581', email: 'pablito2@gmail.com',
      rol: 0, admin: 0
    )
    assert_equal @user1.valid?, true
    assert_equal @user2.valid?, false
  end

  def test_double_dni
    @user1  = User.create(
      name: 'Pepito', surname: 'Clavito',
      dni: 12_345_678, username: 'Clavo02',
      password: '112358', email: 'pablito1@gmail.com',
      rol: 0, admin: 0
    )
    @user2  = User.create(
      name: 'Pepito', surname: 'Clavito',
      dni: 12_345_678, username: 'Clavo02',
      password: '1123581', email: 'pablito2@gmail.com',
      rol: 0, admin: 0
    )
    assert_equal @user1.valid?, true
    assert_equal @user2.valid?, false
  end

  def test_double_email
    @user1  = User.create(
      name: 'Pepito', surname: 'Clavito',
      dni: 12_345_678, username: 'Clavo02',
      password: '112358', email: 'pablito2@gmail.com',
      rol: 0, admin: 0
    )
    @user2  = User.create(
      name: 'Pepito', surname: 'Clavito',
      dni: 12_345_678, username: 'Clavo02',
      password: '1123581', email: 'pablito2@gmail.com',
      rol: 0, admin: 0
    )
    assert_equal @user1.valid?, true
    assert_equal @user2.valid?, false
  end
end
