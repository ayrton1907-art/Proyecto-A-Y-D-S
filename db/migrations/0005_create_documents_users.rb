# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:documents_users) do
      foreign_key :document_id, :documents, null: false
      foreign_key :user_id, :users, null: false
      primary_key %i[document_id user_id]
      index %i[document_id user_id]
    end
  end
  down do
    drop_table :document_users
  end
end
