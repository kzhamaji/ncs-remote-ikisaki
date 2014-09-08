# vim: ts=8 sts=2 sw=2 et

require 'sequel'

Sequel.migration do

  up do
    add_column :actions, :office, String
    from(:actions).update(:office => 'Shinyokohama')
    alter_table(:actions) do 
      set_column_not_null :office
    end
  end

  down do
    drop_column :actions, :office
  end

end
