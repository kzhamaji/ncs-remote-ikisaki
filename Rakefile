# vim: ts=8 sts=2 sw=2 et


namespace :db do
  desc "migrate database"
  task :migrate, [:version] do |t, args|
    require 'sequel'
    Sequel.extension :migration
    require './dbs/connect'
    version = args[:version]
    if version
      puts "Migrating to version #{version}"
      Sequel::Migrator.run(DB, './dbs', :target=> version.to_i)
    else
      puts "Migrating to latest"
      Sequel::Migrator.run(DB, './dbs')
    end
  end
end
