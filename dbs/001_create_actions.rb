# vim: ts=8 sts=2 sw=2 et

require 'sequel'

Sequel.migration do

  change do
    create_table :actions do
      primary_key :id
      integer :enum, :null=>false
      integer :date, :null=>false
      string  :action, :null=>false
      string  :behavior, :null=>false
      string  :value
      timestamp :posted_date
    end
  end

end
