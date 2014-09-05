# vim: ts=8 sts=2 sw=2 et

require 'sequel'

DB_URL = ENV['DATABASE_URL'] || 'postgres://postgres@localhost/ncs_remote_ikisaki'
DB = Sequel.connect(DB_URL)
