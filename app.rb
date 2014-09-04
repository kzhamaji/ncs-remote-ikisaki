# vim: ts=8 sts=2 sw=2 et

require 'sinatra'

require 'slim'
require 'sass'

require 'json'

Slim::Engine.default_options[:pretty] = true

require './model/action.rb'

enable :method_override

# Stylesheet
get '/*.css' do |base|
  content_type 'text/css', :charset=>'utf-8'
  sass base.to_sym
end

get '/' do
  @actions = Actions.order_by(:posted_date)
  slim :index
end

post '/tomorrow' do
  Actions.create({
    :num => request[:num],
    :action => 'tomorrow',
    :date => Time.new(*[:year, :month, :day].map{|k| request[k] }).to_i,
    :hour => request[:hour],
    :minute => request[:minute],
    :posted_date => Time.now
  })
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
  when "between"
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

get %r{/api/actions/(older_than|between)/(\d+(?:/\d+){0,2})} do |kind, date|
  actions = Actions.filter(:date => _date_to_range(kind, date))
  content_type 'text/json'
  [200, actions.map(&:to_hash).to_json]
end

delete %r{/api/actions/(older_than|between)/(\d+(?:/\d+){0,2})} do |kind, date|
  actions = Actions.filter(:date => _date_to_range(kind, date))
  if actions.empty?
    204
  else
    actions.delete
    200
  end
end
