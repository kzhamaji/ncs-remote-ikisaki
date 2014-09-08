# vim: ts=8 sts=2 sw=2 et

require 'sinatra'
require 'sinatra/cookies'
require 'sinatra/json'
require 'sinatra/reloader' if development?

require 'slim'
require 'sass'

Slim::Engine.default_options[:pretty] = true

require './dbs/connect'
require './model/action'

set :cookie_options, { :expires => Time.new(2037, 6, 9) }
enable :method_override

# Stylesheet
get '/*.css' do |base|
  content_type 'text/css', :charset=>'utf-8'
  sass base.to_sym
end

get '/' do
  @actions = Actions.order_by(:posted_date)

  now = Time.now 
  today = now.to_date
  @nday = now.hour < 9 ? today : today + 1
  case @nday.cwday
  when 6
    @nday += 2
  when 7
    @nday += 1
  end
  next_month = @nday >> 1
  @lastday = (Date.new(next_month.year, next_month.month, 1) - 1).day
  @enum = cookies[:enum]
  @office = cookies[:office]

  slim :index
end

post '/tomorrow' do
  enum = request[:enum]
  office = request[:office]
  behavior = request[:behavior]
  date = Time.new(*[:year, :month, :day].map{|k| request[k] }).to_i
  action = {
    :enum => enum.to_i,
    :office => office,
    :date => date,
    :action => 'tomorrow',
    :behavior => behavior,
    :posted_date => Time.now
  }
  action[:value] = case behavior
                   when 'onduty'
                     [request[:hour], request[:minute]].join(':')
                   when 'triphome', 'tripoffice'
                     request[behavior.to_sym]
                   end
  Actions.filter(:enum => enum, :date => date, :action => 'tomorrow').delete
  Actions.create(action)
  cookies[:enum] = enum
  cookies[:office] = office
  redirect '/'
end

def fin (api, num)
  if api
    num
  else
    redirect '/'
  end
end

delete %r{(/api)?/actions} do |api|
  n = DB[:actions].delete
  fin(api, n > 0 ? 200 : 204)
end

delete %r{(/api)?/action/(\d+)} do |api, id|
  Actions.filter(:id => id).delete
  fin(api, 200)
end

require 'date'

def _date_to_range (kind, date)
  y, m, d = date.split('/').map(&:to_i)
  case kind
  when "by_date"
    if m.nil?
      from = Time.new(y, 1, 1)
      to = Time.new(y+1, 1, 1)
    elsif d.nil?
      from = Time.new(y, m, 1)
      to = (from.to_date >> 1).to_time
    else
      from = Time.new(y, m, d)
      to = (from.to_date + 1).to_time
    end
  when "older_than"
    from = Time.at(0)
    to = Time.new(y, m || 1, d || 1)
  end
  (from.to_i)...(to.to_i)
end

get %r{/api/actions/(older_than|by_date)/(\d+(?:/\d+){0,2})} do |kind, date|
  actions = Actions.filter(:date => _date_to_range(kind, date))
  json actions.map(&:to_hash)
end

delete %r{/api/actions/(older_than|by_date)/(\d+(?:/\d+){0,2})} do |kind, date|
  actions = Actions.filter(:date => _date_to_range(kind, date))
  if actions.empty?
    204
  else
    actions.delete
    200
  end
end

get %r{/api/actions/(\w+)/(older_than|by_date)/(\d+(?:/\d+){0,2})} do |office,kind, date|
  actions = Actions.filter(:office => office, :date => _date_to_range(kind, date))
  json actions.map(&:to_hash)
end
