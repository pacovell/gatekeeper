require File.join(File.dirname(__FILE__),'../init.rb')
require File.join(File.dirname(__FILE__),'../lib/routing.rb')

ActionController::Routing::RouteSet::Mapper.send :include, Gatekeeper::Routing::MapperExtensions