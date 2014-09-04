# vim: ts=8 sts=2 sw=2 et

require 'sequel'

Sequel.migration do

  change do
    create_table :actions do
      primary_key :id
      Integer :enum, :null=>false
      Integer :date, :null=>false
      String  :action, :null=>false
      String  :behavior, :null=>false
      String  :value
      timestamp :posted_date
    end
  end

end
