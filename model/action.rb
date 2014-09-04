# vim: ts=8 sts=2 sw=2 et

require 'sequel'

Sequel::Model.plugin(:schema)

DB = Sequel.connect('sqlite://dbs/action.db')


class Actions < Sequel::Model

  unless table_exists?
    set_schema do
      primary_key :id
      integer :enum, :null=>false
      inetger :date, :null=>false
      string  :action, :null=>false
      string  :behavior, :null=>false
      string  :value
      timestamp :posted_date
    end
    create_table
  end

end
