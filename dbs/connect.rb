# vim: ts=8 sts=2 sw=2 et

require 'sequel'

DB_URL = ENV['DATABASE_URL'] || 'sqlite://dbs/action.db'
DB = Sequel.connect(DB_URL)
