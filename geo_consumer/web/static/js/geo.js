export class Geo {

  constructor() {
    var lat = 52.5243700,
        long = 13.4105300;

    this.map = new google.maps.Map(document.getElementById("map"), {
      zoom: 13,
      center: {lat: lat, lng: long, alt: 0}
    })
    // console.log("constructing", this.map);
     //
    //  this.stream = new google.maps.MVCArray();
     //
    //  var markers = new google.maps.visualization.Map({
    //    data: this.stream,
    //    radius: 25
    //  });
    //  markers.setMap(this.map);



    // var width = 950,
    //     height = 550;
    //
    // // set projection
    // var projection = d3.geo.mercator();
    // // projection.scale(1000).center([-106, 37.5])
    //
    // // create path variable
    // var path = d3.geo.path().projection(projection);
    //
    // this.svg = d3.select("body").append("svg")
    //   .attr("width", width)
    //   .attr("height", height);
    //
    // var aa = [-122.49, 37.78];
    // // bb = [-122.389809, 37.72728];
    // this.svg.append("path")
    //   // .datum(topojson.mesh(topo, topo.objects.states, function(a, b) { return a !== b; }))
    //   .attr("class", "mesh")
    //   .attr("d", path)
    //   //     // add circles to svg
    //   .selectAll("circle")
    //   .data([aa]).enter()
    //   .append("circle")
    //   .attr("cx", function (d) { console.log(projection(d)); return projection(d)[0]; })
    //   .attr("cy", function (d) { return projection(d)[1]; })
    //   .attr("r", "4px")
    //   .attr("fill", "red")
  }

  draw(coordinates) {
    let x = coordinates.coord[0],
        y = coordinates.coord[1];
    // console.log("coords: ", x, y)
    var loc = new google.maps.LatLng(x, y);
    // this.stream.push(loc);
    var marker = new google.maps.Marker({
      position: loc,
      map: this.map,
      // icon: image
    })
    marker.setMap(this.map);
    // setTimeout(function(){
    //   marker.setMap(null);
    // },600);
  }

}
