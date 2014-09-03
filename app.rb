# vim: ts=8 sts=2 sw=2 et

require 'sinatra'

get '/' do
  @text = 'hi'
  erb :index
end
