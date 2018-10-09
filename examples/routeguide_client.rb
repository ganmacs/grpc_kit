# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('./examples/routeguide')

require 'grpc_kit'
require 'pry'
require 'json'
require 'routeguide_services_pb'

RESOURCE_PATH = './examples/routeguide/routeguide.json'

def get_feature(stub)
  points = [
    Routeguide::Point.new(latitude:  409_146_138, longitude: -746_188_906),
    Routeguide::Point.new(latitude:  0, longitude: 0)
  ]

  points.each do |pt|
    feature = stub.get_feature(pt)
    puts "get_feature #{feature.name}, #{feature.location}"
  end
end

def list_features(stub)
  rect = Routeguide::Rectangle.new(
    lo: Routeguide::Point.new(latitude: 400_000_000, longitude: -750_000_000),
    hi: Routeguide::Point.new(latitude: 420_000_000, longitude: -730_000_000),
  )

  resps = stub.list_features(rect)
  resps.each do |r|
    puts "list_features #{r.name} at #{r.location.inspect}"
  end
end

def record_route(stub, size)
  features = File.open(RESOURCE_PATH) do |f|
    JSON.parse(f.read)
  end

  stream = stub.record_route({})

  size.times do
    location = features.sample['location']
    pt = Routeguide::Point.new(latitude: location['latitude'], longitude: location['longitude'])
    puts "- next point is #{pt.inspect}"
    stream.send(pt)
    sleep(rand(0..1))
  end

  resp = stream.close_and_recv
  puts "summary: #{resp.inspect}"
end

stub = Routeguide::RouteGuide::Stub.new('localhost', 50051)

# get_feature(stub)
# list_features(stub)
# record_route(stub, 10)
record_route(stub, 10)
