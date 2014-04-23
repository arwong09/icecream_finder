class ReviewsController < ApplicationController
  def index
    @reviews = Review.all
  end
  
  def show
    @review = Review.find(params[:id])
  end
  
  def new
    @review = Review.new
  end
  
  def create
    def current_location
      current_location_url = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/geocode/json",
        :query_values => {
          :address => "1061 Market Street, San Francisco, CA, 94103",
          :sensor => "false"}
      ).to_s

      response = RestClient.get(current_location_url)
      results = JSON.parse(response)
      results["results"][0]["geometry"]["location"]
    end

    def nearby_locations(lat, lng, keyword)
      nearby_url = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/place/nearbysearch/json",
        :query_values => {
          :key => "AIzaSyDSPEHKkyruYPzbSnAB4Bc7WOPMLljHnfY",
          :location => "#{lat}, #{lng}",
          :radius => "5000",
          :sensor => "false",
          :keyword => keyword,
          :rank_by => "distance"}
      ).to_s

      response = RestClient.get(nearby_url)
      results = JSON.parse(response)
      name = results["results"][0]["name"]
      lat_lng = results["results"][0]["geometry"]["location"]

      [name, lat_lng["lat"], lat_lng["lng"]]
    end

    def directions(origin, destination)
      directions_url = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/directions/json",
        :query_values => {
          :origin => "#{origin["lat"]}, #{origin["lng"]}",
          :destination => "#{destination[1]}, #{destination[2]}",
          :sensor => "false",
          :mode => "walking"}
      ).to_s

      response = RestClient.get(directions_url)
      results = JSON.parse(response)
    end

    def print_directions(results, name)
      dir_str = "<strong>Directions to #{name}</strong><br>
      Start Address: #{results["routes"][0]["legs"][0]["start_address"]} <p />"
      steps = results["routes"][0]["legs"][0]["steps"]
      dir_str << "<ol>"
      steps.each do |k, v|
        dir_str << "<li>" << k["html_instructions"].gsub(/<.+?>/, " ").gsub("  ", " ")  
        dir_str << "<br />"
        dir_str << "for #{k["distance"]["text"]}"
        dir_str << "</li>"
      end
      
      dir_str += "</ol>End Address: #{results["routes"][0]["legs"][0]["end_address"]}"
      dir_str.html_safe
    end

    cl = current_location
    dst = nearby_locations(cl["lat"], cl["lng"], params[:review][:restaurant])
    dir = directions(cl, dst)
    
    @review = Review.new(
      restaurant: params[:review][:restaurant],
      body: print_directions(dir, dst[0]))
    @review.save
    
    redirect_to review_path(@review)
  end
end
