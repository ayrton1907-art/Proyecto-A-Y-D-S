Sequel.migration do
  up do
    create_table(:documents) do
      primary_key :id
      String :name, null: false
      String :description, null: false
      Date :date, null: false
      String :fileDocument, null: false
    end
  end

  down do
    drop_table(:documents)
  end
end