
const SpotifyWebApi = require('spotify-web-api-node');
dict_segmentID = {
    "Music":"KZFzniwnSyZfZ7v7nJ",
    "Sports": "KZFzniwnSyZfZ7v7nE",
    "Arts & Theatre":"KZFzniwnSyZfZ7v7na",
    "Film": "KZFzniwnSyZfZ7v7nn",
    "Miscellaneous": "KZFzniwnSyZfZ7v7n1"
}

var geohash = require('ngeohash');

const express = require('express');
const path=require('path');
const app = express();
const axios = require('axios').default;
var bodyParser = require('body-parser');

const angpath=path.join(__dirname, 'dist');
console.log(angpath);
app.use('/', express.static(angpath));

// app.use(express.static(path.join(__dirname, 'dist', 'my-dream-app')));
// app.use('/*', function(req,res){
//     res.sendFile(path.join(__dirname +'/dist/my-dream-app/index.html'));
// })


API_KEY = "";
const PORT =process.env.PORT || 3000;

const cors = require('cors')

var corsOptions = {
//   origin: 'http://localhost:4200',
  origin:'*',
  optionsSuccessStatus: 200
}

app.use(cors(corsOptions))



// app.use(cors());
app.use(bodyParser.json()); 
app.use(bodyParser.urlencoded({ 
  extended: true
}));


app.get('/getdata', async (req, res) =>{
    try{

      console.log("req");
      console.log(req)
    var keyword=req.query.keyword;
    var distance=req.query.distance;
    var location=req.query.location;
    var category=req.query.category;
    var lat=req.query.lat;
    var lng=req.query.long;
    console.log(lat,lng)
    console.log("abcghjfl")
    var geoPoint=geohash.encode(lat,lng, 7);
    console.log("category");
    console.log(category);

    if (distance==0){
        distance=10;
    }
    console.log(geoPoint);
    var segmentID='';

    if (category!="Default"){
      segmentID=dict_segmentID[category];
    }

    else{
      segmentID='';
    }
    console.log(`https://app.ticketmaster.com/discovery/v2/events.json?apikey=${API_KEY}&keyword=${keyword}&radius=${distance}&unit=miles&segmentId=${segmentID}&geoPoint=${geoPoint}`)
    console.log("Segment)");
    console.log(segmentID)
    console.log("parameters");
    console.log(keyword,distance,location);

        const tabresponse=await axios.get(`https://app.ticketmaster.com/discovery/v2/events.json?apikey=${API_KEY}&keyword=${keyword}&radius=${distance}&unit=miles&segmentId=${segmentID}&geoPoint=${geoPoint}`)
      
        // const autocomplete=suggresponse.data._embedded?.attractions?.map((attraction)=>{
        //     console.log(attraction.name)
        //     return attraction.name;
        // })

        console.log("tableresp")
        console.log(tabresponse);


      const tabdata=tabresponse.data;
      console.log(tabdata);
      res.send(tabdata);

 
    }
    
    catch(error){
        console.log(error)
    }

  });
      


app.get('/getevent', async (req, res) =>{
    try{
      var eID=req.query.id;

      console.log(`https://app.ticketmaster.com/discovery/v2/events.json?apikey=Z3ZZ0HqSBAnjLGhrJVne6ajpAuUa2upX&id=${eID}`);

      const response = await axios.get(`https://app.ticketmaster.com/discovery/v2/events.json?apikey=Z3ZZ0HqSBAnjLGhrJVne6ajpAuUa2upX&id=${eID}`);
      
      let e_details = response.data;
      console.log("this is from node js"+e_details);
      res.send(e_details);
    } catch(error){
      console.log(error);
    }
});
  


  
  app.get('/getspotify', async (req, res) => {
    var art_name=req.query.artist;
    // console.log("*******************");
    // console.log(req.query);
    // console.log("ARTIST")
    // console.log(art_name)
    // console.log();
    const spotifyApi = new SpotifyWebApi({
        clientId: '',
        clientSecret: '',
      }) 

      try{const result= await spotifyApi.clientCredentialsGrant()

    spotifyApi.setAccessToken(result.body['access_token']);
    console.log(result.body['access_token'])

    // Use the searchArtists() method to search for the artist
    const artistData= await spotifyApi.searchArtists(art_name);
    console.log("artist DATAAAAAAAAAAAAAAAA");
    console.log(artistData);
    console.log("len");
    // console.log(artistData.body.artists.items);
    

    // if (artistData.body.artists.hasOwnProperty('items')){
        
    //     if (artistData.body.artists.items[0]){
    //         if(artistData.body.artists.items[0].hasOwnProperty('id')){

      
    
    const albumData=await spotifyApi.getArtistAlbums(artistData.body.artists.items[0].id);
    const albums3 = albumData.body.items;
    albums3.sort((a, b) => b.popularity - a.popularity);
    const top3 = albums3.slice(0, 3);
    console.log("TOP 3 ALBUMSSSSSSSSSSSSSS");
    console.log(top3);
    const spotResp={
        artistData,
        top3
    };
    res.json(spotResp);}

    catch(error){console.log(error);
    }
  
  });

  app.get('/getvenue', async (req, res) => {
    try{
    console.log("in get venue")
    var venName=req.query.keyword;
    console.log(venName);
    console.log("VENUEEEEEEE");
    console.log(req.query)

    axios
      .get(`https://app.ticketmaster.com/discovery/v2/venues.json?apikey=&keyword=${venName}`)
      .then(venresp => {
        let vendetail = venresp.data;
         console.log(vendetail);
        res.send(vendetail);
      })
      .catch(err => console.log(err));}
      catch(error){
        console.log(error)
      }
  });

  app.get('/autocomplete', async(req,res)=>{

    try{

    
    const key=req.query.keyword;
    if (key){
    const suggresponse=await axios.get(`https://app.ticketmaster.com/discovery/v2/suggest?apikey=&keyword=${key}`)
  
    const autocomplete=suggresponse.data._embedded?.attractions?.map((attraction)=>{
        console.log(attraction.name)
        return attraction.name;
    })
    res.json(autocomplete);
}
else{
    const autocomplete=[];
    res.json(autocomplete)
}}
catch(error){
    console.log(error)
}
    });

app.listen(PORT, () => console.log(`listening on port ${PORT} `));

