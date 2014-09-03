# vim: ts=8 sts=2 sw=2 et

require 'sinatra'
require 'slim'

get '/' do
  @text = 'hi'
  slim :index
end
