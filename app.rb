require 'sinatra'
require 'csv'
require 'pry'
require 'kmeans-clusterer'
require 'json'

Cluster = Struct.new(:lat, :lng, :size)

class App < Sinatra::Base
  get '/' do
    send_file 'index.html'
  end

  get '/get_clusters' do
    locations = []
    CSV.foreach('./go_track_trackspoints.csv').map do |row|
      locations.push([row[1].to_f, row[2].to_f])
    end

    kmeans = KMeansClusterer.run(12, locations, labels: [], runs: 3)
    clusters = kmeans.clusters.map do |cluster|
      centroid = cluster.centroid
      Cluster.new( centroid.data[1], centroid.data[0], cluster.points.size )
    end

    clusters.map(&:to_h).to_json
  end
end