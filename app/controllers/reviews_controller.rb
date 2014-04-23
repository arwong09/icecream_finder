class ReviewsController < ApplicationController
  def index
    @reviews = Review.all
    p "this is REVIEW!!!!!"
    p @review
    # def nearby_locations(keyword)
 #      nearby_url = Addressable::URI.new(
 #        :scheme => "https",
 #        :host => "maps.googleapis.com",
 #        :path => "maps/api/place/nearbysearch/json",
 #        :query_values => {
 #          :key => "AIzaSyDSPEHKkyruYPzbSnAB4Bc7WOPMLljHnfY",
 #          :location => "37.7810492, -122.4115109",
 #          :radius => "5000",
 #          :sensor => "false",
 #          :keyword => keyword,
 #          :rank_by => "distance"}
 #      ).to_s
 # 
 #      response = RestClient.get(nearby_url)
 #      results = JSON.parse(response)
 #      name = results["results"][0]["name"]
 #      lat_lng = results["results"][0]["geometry"]["location"]
 # 
 #      [name, lat_lng["lat"], lat_lng["lng"]]
 #    end
 #    
    # nb = nearby_locations(params[:review][:restaurant])
#     p "NBNBNBNBN!"
#     p nb
#     @lat = nb[1]
#     @lng = nb[2]
  end
  
  def show
    @review = Review.find(params[:id])
  end
  
  def new
    @review = Review.new
  end
  
  def create
    # def current_location
#       current_location_url = Addressable::URI.new(
#         :scheme => "https",
#         :host => "maps.googleapis.com",
#         :path => "maps/api/geocode/json",
#         :query_values => {
#           :address => "1061 Market Street, San Francisco, CA, 94103",
#           :sensor => "false"}
#       ).to_s
# 
#       response = RestClient.get(current_location_url)
#       results = JSON.parse(response)
#       results["results"][0]["geometry"]["location"]
#     end

    def nearby_locations(keyword)
      nearby_url = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/place/nearbysearch/json",
        :query_values => {
          :key => "AIzaSyDSPEHKkyruYPzbSnAB4Bc7WOPMLljHnfY",
          :location => "37.7810492, -122.4115109",
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

    def directions(destination)
      directions_url = Addressable::URI.new(
        :scheme => "https",
        :host => "maps.googleapis.com",
        :path => "maps/api/directions/json",
        :query_values => {
          :origin => "37.7810492, -122.4115109",
          :destination => "#{destination[1]}, #{destination[2]}",
          :sensor => "false",
          :mode => "walking"}
      ).to_s

      response = RestClient.get(directions_url)
      results = JSON.parse(response)
    end

    def print_directions(results, name)
      dir_str = "<strong>Directions to #{name}</strong><br>"
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
    
    def img_url(keyword)
      keyword = keyword.gsub(" ", "%20")
      "https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=#{keyword}.json"
    end
    
    @keyword = params[:review][:restaurant]
    dst = nearby_locations(@keyword)
    dir = directions(dst)
    img = img_url(@keyword)
    img = JSON(RestClient.get(img))
    img = img["responseData"]["results"][0]["url"]

    
    @review = Review.new(
      restaurant: params[:review][:restaurant],
      body: print_directions(dir, dst[0]),
      img: img)
    @review.save
    
    redirect_to review_path(@review)
  end
end
