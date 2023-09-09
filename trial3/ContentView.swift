//
//  ContentView.swift
//  trial3
//
//  Created by Purva Ingle on 4/13/23.
//

import SwiftUI
import Alamofire
import Kingfisher
import MapKit
import Combine


//https://finalsubhw8.uw.r.appspot.com/getevent?id=

//struct ViewTable: Codable{
//    var results: [Result]
//
//}

// credits:conversion to M/K stack overflow : https://stackoverflow.com/questions/36376897/swift-2-0-format-1000s-into-a-friendly-ks
extension Int {
    var roundedNum: String {
        let number = Double(self)
        let thousand = number / 1000
        let million = number / 1000000
        if million >= 1.0 {
            return "\(round(million*10)/10)M"
        }
        else if thousand >= 1.0 {
            return "\(round(thousand*10)/10)K"
        }
        else {
            return "\(self)"
        }
    }
}

struct Result: Codable, Identifiable{
    var id = UUID()
    var e_id: String
    var name: String
    var venue: String
    var date: String
    var time: String
    var icon: String
}

struct EventRow: View{
    var e_row: Result
//    @State var event_page: [EventDetailsTab] = []
    
    
    var body: some View {
//        Text("Results")
        
//        if e_row.isEmpty {
//            Text("No Results Available")
//        }
//
        HStack{
            VStack{
                Text(e_row.date)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                Text(e_row.time)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
//                loadEventDetails();
            }
            KFImage.url(URL(string: e_row.icon))
                        .placeholder {
                            // Placeholder image while loading
                            Image(systemName: "photo")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
            
            Text(e_row.name)
            Text(e_row.venue)
                .font(.subheadline)
                .foregroundColor(Color.gray)
        }
        .toolbarTitleMenu {
        
        }
    }
}

struct Artist: Codable, Identifiable, Hashable {
    var id = UUID()
    let name: String
    let followers: Int
    let popularity: Int
    let spotifyUrl: String
    let img: String
    let alb_images: [String]
}

struct Venue: Codable, Identifiable, Hashable{
    var id = UUID()
//    let e_name : String
//    let v_name : String
    var address : String = ""
    var number : String = ""
    var OH : String = ""
    var GR : String = ""
    var CR : String = ""
}

struct SpotifyProgView: View {
    @State var progress : Int
    
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color.red.opacity(0.5),
                    lineWidth: 20
                )
                .frame(width: 60.0, height: 60.0)

            let prog = CGFloat(self.progress)/100.0
            Circle()
                .trim(from: 0, to: prog)
                .stroke(
                    Color.red,
                    lineWidth: 20
                )
                .frame(width: 60.0, height: 60.0)
                

        }
    }
}

struct MyMaps: Codable, Identifiable, Hashable{
    var id = UUID()
    var lat: String
    var lng: String

}
struct Location: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MyMapView: View {
    @State var latitude: Double
    @State var longitude: Double
    
    
    var body: some View {
        let location = Location(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        Map(coordinateRegion: .constant(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))), annotationItems: [location]) { place in
                    MapMarker(coordinate: place.coordinate, tint: .red)
                }.edgesIgnoringSafeArea(.all)
    }
}

struct Favorites: Codable, Identifiable, RandomAccessCollection, Equatable {
    var id = UUID()
    var f_id : String
     var f_date: String
     var f_name: String
     var f_genre: String
     var f_venue: String
    
    typealias Index = Int
        var startIndex: Int { 0 }
        var endIndex: Int { 1 }
        subscript(position: Int) -> Favorites { self }
    
}

//credits : for toast I used https://stackoverflow.com/questions/56550135/swiftui-global-overlay-that-can-be-triggered-from-any-view
struct Toast<Presenting, Content>: View where Presenting: View, Content: View {
    @Binding var isPresented: Bool
    let presenter: () -> Presenting
    let content: () -> Content
    let delay: TimeInterval = 2

    var body: some View {
        if self.isPresented {
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                withAnimation {
                    self.isPresented = false
                }
            }
        }

        return GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                self.presenter()

                ZStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .cornerRadius(10)

                    self.content()
                }
                .frame(width: geometry.size.width / 1.25, height: geometry.size.height / 10)
                .opacity(self.isPresented ? 1 : 0)
            }
            .padding(.bottom)
        }}}

extension View {
    func toast<Content>(isPresented: Binding<Bool>, content: @escaping () -> Content) -> some View where Content: View {
        Toast(
            isPresented: isPresented,
            presenter: { self },
            content: content
        )
    }
}



struct EventDetails: View{
    var e_id: String
    @State var showeventdetail = false
    @State private var selectedTab = 0
    //    @State var eventDetails: [String: Any] = [:]
    //    @State var evt_page : EventDetailsPage
    //    var e_id: String
    @State var name: String
    @State var date: String
    @State var venue: String
    @State var artist: String
    @State var genre: String
    @State var minprice: Double
    @State var maxprice: Double
    @State var stmp: String
    @State var TM: String
    @State var TS: String
    @State var music: Bool
    @State var artist_names: [String]
    @State var spot: [Artist] = []
    @State var ven: [Venue] = []
    @State var mps: [MyMaps] = []
    @State var showmap: Bool
    @State private var isFavorite = false
    @State var Twitter : String
    @State private var showToast: Bool = false

    
    var body: some View{
                
        TabView {
            VStack{
                
                if (showeventdetail){
                    Text(self.name)
                        .font(.title2)
                        .fontWeight(.regular)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Date")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            Text(self.date)
                                .font(.subheadline)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Artist | Team")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            Text(self.artist)
                                .font(.subheadline)
                        }
                        
                    }
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Venue")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            Text(self.venue)
                                .font(.subheadline)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Genre")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            Text(self.genre)
                                .font(.subheadline)
                        }
                        
                    }
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Price Range")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            let str_min = String(self.minprice)
                            let str_max = String(self.maxprice)
                            Text(str_min + " - " + str_max)
                                .font(.subheadline)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Ticket Status")
                                .font(.headline)
                                .multilineTextAlignment(.leading)
                            
                            Text(self.TS)
                                .font(.subheadline)
                                .padding(12)
                                .background(
                                        Group {
                                            switch self.TS {
                                            case "onsale":
                                                Color.green
                                            case "offsale":
                                                Color.red
                                            case "rescheduled":
                                                Color.yellow
                                            case "cancelled":
                                                Color.black
                                            case "postponed":
                                                Color.orange
                                            default:
                                                Color.gray
                                            }
                                        }
                                    )
                                    .cornerRadius(5)
                        }
                        
                    }
                    
                    VStack {
                        Button(action:
                                {
                            self.isFavorite.toggle()
                            withAnimation {
                                                   self.showToast = true
                                               }
                            
                            
                            let favEvent = Favorites(f_id:self.e_id ,f_date:self.date, f_name: self.name, f_genre: self.genre, f_venue: self.venue)
                                
                                let encoder = JSONEncoder()
//                                var favorites : [Favorites] = []
                                let decoder = JSONDecoder()
                            let defaults = UserDefaults.standard
//                            if self.isFavorite {
                                
                                if let f_data = defaults.data(forKey: self.e_id){
                                    if let decoded =  try? decoder.decode(Favorites.self, from: f_data) {
                                        print("abcd")
                                    }
                                    
                                    defaults.removeObject(forKey: self.e_id)
                                    
                                }
                                else{
                                    let encoded = try? encoder.encode(favEvent)
                                    defaults.set(encoded, forKey: self.e_id)
                                }
                                
                               
                        })
                            {
                            Text(self.isFavorite ? "Remove Favorite." : "Save event")
                                
                                .foregroundColor(.white)
                                .padding(20)
                                .frame(width: 170)
                               .background(self.isFavorite ? Color.red : Color.blue)
                                .cornerRadius(15)
                            
                    }
                        KFImage.url(URL(string: self.stmp))
                                    .placeholder {
                                        // Placeholder image while loading
                                        
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                        
                        HStack {
                            Text("Buy Ticket At: ")
                                .font(.headline)
                            Text("Ticketmaster")
                                .foregroundColor(Color.blue)
                                .onTapGesture {
                                    guard let url = URL(string: self.TM) else { return }
                                        UIApplication.shared.open(url)
                                    }

//                            Link("TicketMaster", destination: URL(string: self.TM))
                        }
                        HStack {
                            Text("Share On: ")
                                .font(.headline)

                            Button(action: {
                                guard let url = URL(string: "https://www.facebook.com/sharer/sharer.php?u=" + self.TM + "&amp;src=sdkpreparse") else { return }
                                UIApplication.shared.open(url)
                            }) {
                                Image("f_logo")
                                    .resizable()
                                    .frame(width: 26.0, height: 26.0)
                            }
                            //                                    .resizable()
                            //                                    .frame(width: 26.0, height: 26.0)
                            
                            let twit = self.name
                            let encodedString = twit.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                            
                            Button(action: {
                                guard let url = URL(string: "https://twitter.com/intent/tweet?text=" + (encodedString ?? "") + "https://www.ticketmaster.com/hololive-english-1st-concert-connect-the-inglewood-california-07-02-2023/event/0A005E712A3809AD") else { return }
                                UIApplication.shared.open(url)
                            }) {
                                Image("Twitter")
                                    .resizable()
                                    .frame(width: 26.0, height: 26.0)
                            }
                            
                        }
                    }
                }
            }
            .toast(isPresented: self.$showToast) {
                HStack {
                    Text(self.isFavorite ? "Added to favorites." : "Remove Favorite")
                    
                }}
            .tabItem {
                VStack {
                    Image(systemName: "text.bubble.fill")
                    Text("Events")
                }
            }
            .padding(.all)
            .onAppear {
                
                showeventdetail = true
                let url = "https://finalsubhw8.uw.r.appspot.com/getevent?id=\(e_id)"
                AF.request(url).responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        print("EVENT PAGE")
                        print(value)
                        
                        //                        for(var k=0; k<resjson._embedded.events[0]._embedded.attractions.length; ++k){
                        //                                if (resjson._embedded.events[0]._embedded.attractions[k].hasOwnProperty("name")){
                        //                                artists=artists+resjson._embedded.events[0]._embedded.attractions[k].name + ' | '
                        //                                }
                        
                        if let json = value as? [String: Any],
                           let embedded = json["_embedded"] as? [String: Any],
                           let events = embedded["events"] as? [[String: Any]],
                           let event = events.first{
                            if (event["name"] != nil) {
                                self.name = event["name"] as? String ?? ""
                            } else {
                                self.name = ""
                            }
                            
                            
                            if (event["dates"] != nil){
                                let dates = event["dates"] as? [String: Any]
                                if (dates?["start"] != nil){
                                    let start = dates?["start"] as? [String: Any]
                                    if (start?["localDate"] != nil){
                                        self.date = start?["localDate"] as? String ?? ""
                                    }
                                    
                                }
                                
                                if (dates?["status"] != nil){
                                    let status = dates?["status"] as? [String: Any]
                                    if (status?["code"] != nil){
                                        self.TS = status?["code"] as! String
                                        
                                    }
                                }
                            }
                            
                            if let venue = event["_embedded"] as? [String: Any],
                               let venues = venue["venues"] as? [[String: Any]],
                               let firstVenue = venues.first{
                                if (firstVenue["name"] != nil){
                                    self.venue = firstVenue["name"] as? String ?? ""
                                    
                                }}
                            
                            if let classification = event["classifications"] as? [[String: Any]],
                               let firstClassification = classification.first{
                                if let genre = firstClassification["genre"] as? [String: Any],
                                   let genreName = genre["name"] as? String{
                                    if (genreName != "Undefined"){
                                        self.genre = genreName
                                    }
                                }
                                if let subgenre = firstClassification["subGenre"] as? [String: Any],
                                   let subgenreName = subgenre["name"] as? String{
                                    if (subgenreName != "Undefined"){
                                        self.genre = self.genre + " | " + subgenreName
                                    }
                                }
                                
                                if let type = firstClassification["type"] as? [String: Any],
                                   let typeName = type["name"] as? String{
                                    if (typeName != "Undefined"){
                                        self.genre = self.genre + " | " + typeName
                                    }
                                }
                                
                                if let subtype = firstClassification["subType"] as? [String: Any],
                                   let subtypename = subtype["name"] as? String{
                                    if (subtypename != "Undefined"){
                                        self.genre = self.genre + " | " + subtypename
                                    }
                                }
                            }else{
                                self.genre = ""
                            }
                            
                            if let priceRanges = event["priceRanges"] as? [[String: Any]],
                               let firstPriceRange = priceRanges.first,
                               let minPrice = firstPriceRange["min"] as? Double,
                               let maxPrice = firstPriceRange["max"] as? Double{
                                self.minprice = minPrice
                                self.maxprice = maxPrice
                            }
                            if let seatmap = event["seatmap"] as? [String: Any],
                               let seatmapURL = seatmap["staticUrl"] as? String{
                                self.stmp = seatmapURL
                            }else{
                                self.stmp = ""
                            }
                            if let ticketmasterURL = event["url"] as? String {
                                
                                self.TM = ticketmasterURL
                                
                                
                            }else{
                                self.TM = ""
                            }
                            
                            self.Twitter = "https://twitter.com/intent/tweet?text=Check " + self.name + "on Ticketmaster " + self.TM + "&hashtags=hashtag1,hashtag2"
                            print("twitter link")
                            print(self.Twitter)
                            
                            if (event["_embedded"] != nil){
                                let _embedded2 = event["_embedded"] as! [String: Any]
                                
                                if (_embedded2["attractions"] != nil){
                                    let attractions = _embedded2["attractions"] as! [[String: Any]]
                                    var artists = ""
                                    for attraction in attractions {
                                        if let name = attraction["name"] as? String {
                                            artists += name + " | "
                                        }
                                        if let classifications = attraction["classifications"] as? [[String:Any]],
                                           let firstclassf = classifications.first{
                                            if let segment = firstclassf["segment"] as? [String: Any]{
                                                let segmentName = segment["name"] as? String
                                                
                                                if segmentName == "Music"{
                                                    self.music = true
                                                    self.artist_names.append(attraction["name"] as! String)
                                                }
                                                
                                                
                                            }
                                            
                                        }
                                    }
                                    self.artist = artists
                                    
                                    //
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            }
                
            if (self.music == false){
                Text("No music related artist details to show")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                    .tabItem {
                        VStack {
                            Image(systemName: "guitars")
                            Text("Artist/Team")
                        }
                    }
            }
            else{  VStack{
               
                List(spot){ sp in
                    VStack{
                        HStack{
//                            VStack{
                                KFImage.url(URL(string: sp.img))
                                    .placeholder {
                                        // Placeholder image while loading
                                        Image(systemName: "photo")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                    }
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(10)
                                    .frame(width: 100, height: 100)
                                    .padding(5)
//                            }
//                            Spacer()
                            
                            
                            VStack(alignment: .leading){
                                Text(sp.name)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    
                                
                                HStack{
                                    Text(String(sp.followers.roundedNum))
                                        .font(.headline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    Text("Followers")
                                        .font(.subheadline)
                                        .fontWeight(.regular)
                                        .foregroundColor(.white)
                                    
                                }
                                
                                HStack{
                                    Image("spotify_logo")
                                        .resizable()
                                            .frame(width: 26.0, height: 26.0)
                                    Text("Spotify")
                                       
                                        .foregroundColor(.green)
                                        .onTapGesture {
                                            guard let url = URL(string: sp.spotifyUrl) else { return }
                                            UIApplication.shared.open(url)
                                        }
                                    
                                }
                                                            }.padding(5)
//                            Spacer()
                            
                            VStack{
                                Text("Popularity")
                                    .foregroundColor(.white)
//                                Text(String(sp.popularity))
//                                    .foregroundColor(.white)
                                            ZStack {
                                                // 2
                                                SpotifyProgView(progress: sp.popularity)
                                                // 3
                                                Text("\(sp.popularity)")
                                                    .foregroundColor(Color.white)

                                            }
                                
                            }.padding(5)
                        }
                        
                        HStack{
                            ForEach(sp.alb_images, id: \.self) { image in
                                KFImage(URL(string: image))
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                                    .padding(5)
                            }
                            
                            
                        }
                        
                        
                        
                    
                        
                    }
                        .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray)
                                )
                                .padding()

                }
               
                
            }
                    .tabItem {
                        VStack {
                            Image(systemName: "guitars")
                            Text("Artist/Team")
                        }
                    }
                    .onAppear(){
                        for art in artist_names{
                            let encodedArt = art.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                            let spotUrl = "https://finalsubhw8.uw.r.appspot.com/getspotify?artist=" + encodedArt!
                            print("heyoooo")
                            print(spotUrl)
                            AF.request(spotUrl).responseJSON { response in
                                switch response.result {
                                case .success(let value):
                                    var a_name = ""
                                    var a_foll = 0
                                    var a_pop = 0
                                    var a_spotLink = ""
                                
                                    var a_img = ""
                                    
                                    if let json = value as? [String: Any],
                                       let artistData = json["artistData"] as? [String:Any],
                                       let body = artistData["body"] as? [String:Any],
                                       let artists = body["artists"] as? [String: Any],
                                       let items = artists["items"] as? [[String: Any]],
                                       let firstitems = items.first{
                                        
                                        
                                        a_name = firstitems["name"] as? String ?? ""
                                        if (firstitems["followers"] != nil){
                                            
                                            let followers = firstitems["followers"] as? [String: Any]
//                                            if (followers?["total"] != nil){
                                                a_foll = followers?["total"] as? Int ?? 0
//                                            }
                                            
                                            
                                            
                                        }
                                        
                                        a_pop = firstitems["popularity"] as? Int ?? 0
                                        
                                        if (firstitems["external_urls"] != nil) {
                                            let ext_urls = firstitems["external_urls"] as? [String:Any]
                                            a_spotLink = ext_urls?["spotify"] as? String ?? ""
                                        }
                                        
                                        if (firstitems["images"] != nil){
                                            let images = firstitems["images"] as? [[String: Any]]
                                            let imagefirst = images?.first as? [String: Any]
                                            a_img = imagefirst?["url"] as? String ?? ""
                                        }
                                        
                                        print("name" + a_name)
                                        print("followers" + String(a_foll))
                                        
                                       
                                        
                                        var albimg: [String] = []
                                        
                                        if let top3 = json["top3"] as? [[String: Any]]{
                                            
                                            
                                            for k in top3 {
                                                
                                                if (k["images"] != nil){
                                                    if let alb_images = k["images"] as? [[String:Any]],
                                                       let firstimg = alb_images.first{
                                                        let url = firstimg["url"]
                                                        
                                                        albimg.append(url as? String ?? "")
                                                    }
                                                    
                                                }
                                                
                                            }
                                            print(albimg)
                                        }
                                        

                                        let artistobj = Artist(name: a_name, followers: a_foll, popularity: a_pop, spotifyUrl: a_spotLink, img: a_img , alb_images: albimg)
                                        
                                        
                                        
                                        self.spot.append(artistobj)
                                    }

                                       
                                case .failure(let error):
                                    print("Error: \(error)")
                                }
                            }
                            }

                            
                            
                        }
//                        print(self.spot)
                        
                    }
            
                
            VStack(alignment: .center) {
                
//                var showmap = false
                
                Text(self.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("Name")
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                Text (self.venue)
                    .font(.subheadline)
                    .padding(.bottom, 10)
                
               
                ForEach(self.ven) { v in
                    Text("Address")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text(v.address)
                        .font(.subheadline)
                        .padding(.bottom, 10)
                    
                    if (v.number != ""){
                        Text("Phone Number")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(v.number)
                            .font(.subheadline)
                            .padding(.bottom, 10)
                    }
                    
                    if (v.OH != ""){
                        Text("Open Hours")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text(v.OH)
                            .font(.subheadline)
                            .padding(.bottom, 10)
                    }
                    
                    if (v.GR != ""){
                        Text("General Rule")
                            .font(.headline)
                            .fontWeight(.bold)
                        ScrollView{
                            Text(v.GR)
                                .font(.subheadline)
                            
                            
                            
                        }.frame(height: 70)
                            .padding(.bottom, 10)
                    }
                    if (v.CR != ""){
                        
                        Text("Child Rule")
                            .font(.headline)
                            .fontWeight(.bold)
                        ScrollView{Text(v.CR)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                        }.frame(height: 70)
                            .padding(.bottom, 10)
                    }
                    
                }
                
                Button(action: {
                    self.showmap = true
                    print("show venue on map ..")
//                    showGM(venueName: self.venue)
                    let encodedVen = self.venue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    
                    let geocodeUrl2 =
                    "https://maps.googleapis.com/maps/api/geocode/json?address=" + encodedVen +  "&key=AIzaSyAsUT6mL4V3D2SQDX5ltEWbuh2C5g0pph4"
                    
                    print(geocodeUrl2)
                    AF.request(geocodeUrl2).responseJSON { response in
                            switch response.result {
                            case .success(let value):
                                if let json = value as? [String: Any],
                                   let results = json["results"] as? [[String: Any]],
                                   let firstResult = results.first,
                                   let geometry = firstResult["geometry"] as? [String: Any],
                                   let location = geometry["location"] as? [String: Any],
                                   let lat = location["lat"] as? Double,
                                   let lng = location["lng"] as? Double
                                    {
                                    
                                    print("latlong")
                                    print(lat)
                                    print(lng)
                                    let mapsObj = MyMaps(lat: String(lat), lng: String(lng))
                                    print(mapsObj)
                                    self.mps.append(mapsObj)
                                    print("self.mps")
                                    print(self.mps)
                                    
                                                    }
                                
                                print("inside tab view maps")
                                
                                print(self.mps)
                                
                                
                            case .failure(let error):
                                print(error)
                            }
                        }
                    
                    
                    
                }) {
                    Text("Show venue on maps")
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
                
                .sheet(isPresented: $showmap) {
                    NavigationView {
                        
                        ForEach(self.mps, id: \.self) { mp in
                            
                            MyMapView(latitude: Double(mp.lat) ?? 0.0, longitude: Double(mp.lng) ?? 0.0)
                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                        }
//                        $showmap = false
                    }
                }
                
                Spacer()
                
            }
            
            .tabItem {
                VStack {
                    Image(systemName: "location.fill")
                    Text("Venue")
                }
            }
        
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    
            .onAppear(){
                let encodedVenue = self.venue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let venueUrl = "https://finalsubhw8.uw.r.appspot.com/getvenue?keyword=" + (encodedVenue ?? "")
                AF.request(venueUrl).responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        var v_name = ""
                        var v_address = ""
                        var phone = ""
                        var openhrs = ""
                        var childrule = ""
                        var genrule = ""
                    
                        if let json = value as? [String: Any],
                           let _embedded = json["_embedded"] as? [String:Any],
                           let venues = _embedded["venues"] as? [[String:Any]],
                           let firstvenue = venues.first{
                            
                            print(firstvenue)
                            print("abc")
                            print(firstvenue["state"]!)
                            print(firstvenue["postalCode"]!)
                            print(firstvenue["city"]!)
                            
                            if let address = firstvenue["address"] as? [String: Any],
                               let line1 = address["line1"] as? String,
                               let state = firstvenue["state"] as? [String: Any],
                               let stateName = state["name"] as? String,
                                let postalcode = firstvenue["postalCode"] as? String,
                               let city = firstvenue["city"] as? [String: Any],
                            let cityname = city["name"] as? String{
                                print(line1)
                                print(city)
                                print(state)
                                            v_address = line1 + cityname + stateName + postalcode
                                print(v_address)
                                        }
                            
                            print(firstvenue["boxOfficeInfo"])
                            
                            if let boxoffice = firstvenue["boxOfficeInfo"] as? [String: Any]{
                                print("pqr")
                                let boxoffice = firstvenue["boxOfficeInfo"] as? [String: Any]
                                if(boxoffice?["phoneNumberDetail"] != nil){
                                    phone = boxoffice?["phoneNumberDetail"] as? String ?? ""
                                }
                                
                                if (boxoffice?["openHoursDetail"] != nil){
                                    openhrs = boxoffice?["openHoursDetail"] as? String ?? ""
                                }
                                
                                
                            }
                            
                            if (firstvenue["generalInfo"] != nil){
                                let geninfo = firstvenue["generalInfo"] as? [String: Any]
                                if (geninfo?["childRule"] != nil){
                                    childrule = geninfo?["childRule"] as? String ?? ""
                                    
                                    genrule = geninfo?["generalRule"] as? String ?? ""
                                }
                                
                            }
                            
                            let venuObj = Venue(address: v_address, number: phone, OH: openhrs, GR: genrule, CR: childrule)
                            
                            self.ven.append(venuObj)
                                                    }
                        
                       
                            
                           
                            
                    case .failure(let error):
                        print("Error: \(error)")
                            }
                            


                           
                        }
                   
                    }
                }

                
            }
        
    }

struct FavoriteEventsView: View {
    
    @State var events : [Favorites] = []
    
    var body: some View {
        VStack{
            
            if self.events.isEmpty {
                Text("No favorites found")
                    
                    .foregroundColor(Color.red)
                        } else {
                            List {
                                ForEach(self.events) { ev in
                                    HStack {
                                        Text(ev.f_date)
                                        Text(ev.f_name)
                                        Text(ev.f_genre)
                                        Text(ev.f_venue)
                                    }
                                }
                                .onDelete{indexSet in
                                    let defaults = UserDefaults.standard
                                    indexSet.forEach { index in
                                            defaults.removeObject(forKey: self.events[index].f_id)
                                        }
                                        self.events.remove(atOffsets: indexSet)
                                        let encoder = JSONEncoder()
                                   
                                    
                                    for item in self.events {
                                        print("a")
                                        if let encoded = try? encoder.encode(item) {
                                            print("b")
                                           
                                            defaults.set(encoded, forKey: item.f_id)}
                                        
                                        
                                    }
                                    
                                    print("event deleted")
//                                    print(self.events)
                        
                                    }

                            }
                            

            }
                
        }
        .onAppear{
            let defaults = UserDefaults.standard
            let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
            for key in allKeys{
                
                if let encodedData = defaults.data(forKey: key) {
                    let decoder = JSONDecoder()
                    if let decodedData = try? decoder.decode(Favorites.self, from: encodedData) {
                        self.events.append(decodedData)
                    }
                }
               
            }
            print(self.events)
            
        }
        .navigationBarTitle("Favorites")
        
    }
    
}
        

    
    struct ContentView: View {
        @State var keyword = ""
        @State var dist = ""
        //    @State var Category = "Default"
        @State var loc = ""
        @State var selected = false
        @State var selectedOPT = 0
        @State var geoloc = 0
        @State var lat = 0.0
        @State var lng = 0.0
        @State private var showResults = false
        @State private var clearStuff = false
        @State var evt: [Result] = []
        @State var sugg: [String] = []
        @State var showsugg: Bool = false
        @State var isLoading = false
        @State var suggLoad = false
        

//        @State var isSliderOn = false
        
        var MakeRed: Bool {
                !keyword.isEmpty && (!loc.isEmpty || selected)
            }
        
        
        let options = ["Default", "Music", "Sports", "Arts & Theatre", "Film", "Miscellaneous"]
        
        func IPSuggest(ip : String) {
//            if (ip.count > 4){
            self.suggLoad = true
                self.showsugg = true
                let encodedip = ip.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                let ipsuggurl = "https://finalsubhw8.uw.r.appspot.com/autocomplete?keyword=" + encodedip
                
                AF.request(ipsuggurl, method: .get)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            if let sugglist = value as? [String]{
                                
                                self.sugg = sugglist
                                
                            }
                            self.suggLoad = false
                                
                                
                                
                                
                                case .failure(let error):
                                    print(error)
                        }
                    }
//            }
            
        }
        var body: some View {
            VStack {
                NavigationView{
                    
                    VStack {
                        
                        
                        Form{
                            HStack{
                                Text("Keyword:")
                                TextField("Required", text: $keyword)
                                    .onSubmit {
                                                    IPSuggest(ip: keyword)
                                        
                                                }
                                
                                    .sheet(isPresented: $showsugg) {
                                        if suggLoad {
                                            Text("Suggestions")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                            HStack {Spacer()
                                                VStack(alignment: .center){
                                                    
                                                    ProgressView()
                                                    
                                                    Text("Please wait...")
                                                        .font(.subheadline)
                                                        .foregroundColor(Color.gray)
                                                }
                                                Spacer()
                                            }
                                            
                                        }
                                        else{
                                            Text("Suggestions")
                                                .font(.title)
                                                .fontWeight(.bold)
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                            List(sugg, id: \.self) { s in
                                                Text(s)
                                                    .onTapGesture {
                                                        self.keyword = s
                                                        self.showsugg = false
                                                    }
                                                
                                            }
  
                                        }
                                    }
                            }
                            
                            HStack{
                                Text("Distance:")
                                TextField("10", text: $dist)
                            }
                            
                            HStack{
                                Picker(selection: $selectedOPT, label: Text("Category:")) {
                                    ForEach(options.indices, id: \.self) { index in
                                        Text(options[index])
                                    }
                                }.pickerStyle(MenuPickerStyle())
                            }
                            if !selected {
                                HStack{
                                    Text("Location:")
                                    TextField("Required", text: $loc)
                                    
                                    
                                }
                            }
                            HStack{
                                
                                Toggle("Auto-detect my location:", isOn: $selected)
                                    .onTapGesture {
                                        selected.toggle()
                                        if selected {
                                            print("Toggle is now ON")
                                            geoloc=1
                                        } else {
                                            print("Toggle is now OFF")
                                            geoloc=0
                                        }
                                    }
                            }
                            
                            HStack{
                                Button(action: {
                                    print("submitted ..")
                                    
                                    isLoading = true
                                    self.evt = []
                                    self.loadEvents();
                                    
                                    
                                    
                                }) {
                                    Text("Submit")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .background(MakeRed ? Color.red : Color.gray)
                                        .cornerRadius(10)
                                    
                                }
                                Spacer()
                                Button(action: {
                                    print("cleared ..")
                                    clearStuff = true
                                    showResults = false
                                    self.evt = []
                                    self.keyword = ""
                                    self.loc = ""
                                    self.selected = false
                                    self.dist = ""
                                    
                                }) {
                                    Text("Clear")
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(minWidth: 0, maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                }
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        
                        if isLoading{
                            List {Text("Results")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                HStack {Spacer()
                                    VStack(alignment: .center){
                                        
                                        ProgressView()
                                            
                                        Text("Please wait...")
                                            .font(.subheadline)
                                            .foregroundColor(Color.gray)
                                    }
                                    Spacer()
                                }
                                
                            }
                        }
                    
                        if ( showResults ){
                            //                    NavigationView{
                            if (self.evt.isEmpty){
                                List {
                                    Text("Results")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Text("No result available")
                                        .font(.subheadline)
                                        .foregroundColor(Color.red)
                                }
                            }
                            else{
                                
                                List (evt.indices, id: \.self) { index in
                                    
                                    if index == 0 {
                                            Text("Results")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        }
                                    
                                    NavigationLink(destination: EventDetails(e_id: evt[index].e_id, name: "", date: "", venue: "", artist: "", genre: "",minprice: 0.0, maxprice: 0.0, stmp: "", TM: "", TS: "", music: false, artist_names: [], ven: [], showmap: false, Twitter : "")) {
                                        
                                       
                                        
                                        VStack{
                                            EventRow(e_row:  evt[index])
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .navigationBarTitle("Event Search")
                    .navigationBarItems(trailing:NavigationLink(destination: FavoriteEventsView()) {
                                            Image(systemName: "heart.circle")
                                                                .foregroundColor(Color.blue)
                                                                .frame(maxWidth: .infinity, maxHeight: 10, alignment: .trailing)
                                                                .padding()
                                                                            })
                }
            }
            
        }
        
        func loadEvents(){
            
            self.evt = []
            self.showResults = false
            self.isLoading = true
//            let keyw = keyword.
            let keywordValue = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
//            let distValue = dist.trimmingCharacters(in: .whitespacesAndNewlines)
            let distValue = dist
            let categoryValue = options[selectedOPT]
            let locValue = loc
            let encodedlocValue = locValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            
            //            let autoDetectValue = selected ? "true" : "false"
            if (geoloc==1){
                
                var ipinfoURL = "https://ipinfo.io/json?token=1601cde681c5d6"
                AF.request(ipinfoURL, method: .get)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            
                            if let jsonresp = value as? [String:Any],
                               let ip_latlong = jsonresp["loc"] as? String{
                                let latlong = ip_latlong.split(separator: ",")
                                self.lat = Double(latlong[0]) ?? 0.0
                                self.lng = Double(latlong[1]) ?? 0.0
//                                print("Latitude: \(self.lat ?? 0), Longitude: \(self.lng ?? 0)")
                                
                                let url = "https://finalsubhw8.uw.r.appspot.com/getdata?keyword=\(keywordValue!)&distance=\(distValue)&category=\(categoryValue)&location=\(encodedlocValue!)&lat=\(lat)&long=\(lng)"
                                print("THis is the URL")
                                print(url)
                                
                                AF.request(url, method: .get)
                                    .validate(statusCode: 200..<300)
                                    .responseJSON { response in
                                        switch response.result {
                                        case .success(let value):
                                            //                                        print(value)
                                            //                                        resultjson.page.totalElements;
                                            if let jsonObj1 = value as? [String: Any],
                                               let tot1 = jsonObj1["page"] as? [String: Any],
                                               let tot2 = tot1["totalElements"] as? Int{
                                                print("TOTAL ELEMENTS")
                                                print(tot2)
                                                
                                                var num=0;
                                                if (tot2>=20){
                                                    num=20;
                                                }
                                                else{
                                                    num=tot2
                                                }
                                                for i in 0..<num{
                                                    print("inside FOR")
                                                    
                                                    if let jsonObject = value as? [String: Any],
                                                       let embedded = jsonObject["_embedded"] as? [String: Any],
                                                       let events = embedded["events"] as? [[String: Any]],
                                                       let venuelist = events[i]["_embedded"] as? [String: Any],
                                                       let venues = venuelist["venues"] as? [[String: Any]],
                                                       let e_name = events[i]["name"] as? String,
                                                       let e_id = events[i]["id"] as? String,
                                                       let dates = events[i]["dates"] as? [String: Any],
                                                       let start = dates["start"] as? [String: Any],
                                                       let date = start["localDate"] as? String,
                                                       let time = start["localTime"] as? String,
                                                       let icon = events[i]["images"] as? [[String: Any]],
                                                       let icon2 = icon.first?["url"] as? String,
                                                       let venueName = venues.first?["name"] as? String {
                                                        print("Date: \(date)")
                                                        print("Time: \(time)")
                                                        print("Event Name: \(e_name)")
                                                        print("Venue Name: \(venueName)")
                                                        
                                                        let s_event = Result(e_id: e_id, name: e_name, venue: venueName, date: date, time: time, icon: icon2)
                                                        self.evt.append(s_event)
                                                        print("s_event")
                                                    }
                                                    
                                                }
                                                
                                                let df = DateFormatter()
                                                df.dateFormat = "yyyy-MM-dd"
                                                let sortedEvt = self.evt.sorted { event1, event2 in
                                                    if let date1 = df.date(from: event1.date), let date2 = df.date(from: event2.date) {
                                                        return date1 < date2
                                                    }
                                                    return false
                                                }
                                                
                                                self.evt = sortedEvt
                                                
                                                self.isLoading = false
                                                self.showResults = true
                                                print(self.evt)
                                            }
                                            
                                        case .failure(let error):
                                            print(error)
                                        }
                                        
                                    }
                            } else{
                                print("error")
                            }
                            
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
            if (geoloc == 0){
                
                let encodedAddress = locValue.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                var geocodeUrl = "https://maps.googleapis.com/maps/api/geocode/json?address=\(encodedAddress)&key=AIzaSyAsUT6mL4V3D2SQDX5ltEWbuh2C5g0pph4"
                
                AF.request(geocodeUrl, method: .get)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        switch response.result {
                        case .success(let value):
                            if let dict = value as? [String: Any], let results = dict["results"] as? [[String: Any]], let geometry = results.first?["geometry"] as? [String: Any], let location = geometry["location"] as? [String: Double] {
                                self.lat = location["lat"] ?? 0.0
                                self.lng = location["lng"] ?? 0.0
//                                print("Latitude: \(lat ?? 0), Longitude: \(lng ?? 0)")
                                
                                let encodedLocValue = locValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                                let url =  "https://finalsubhw8.uw.r.appspot.com/getdata?keyword=\(keywordValue!)&distance=\(distValue)&category=\(categoryValue)&location=\(encodedlocValue!)&lat=\(lat)&long=\(lng)"
                                print("THis is the URL")
                                print(url)
                                
                                AF.request(url, method: .get)
                                    .validate(statusCode: 200..<300)
                                    .responseJSON { response in
                                        switch response.result {
                                        case .success(let value):
                                            var num = 0;
                                            if let jsonObj1 = value as? [String: Any],
                                               let tot1 = jsonObj1["page"] as? [String: Any],
                                               let tot2 = tot1["totalElements"] as? Int{
                                                print("TOTAL ELEMENTS")
                                                print(tot2)
                                                
                                                
                                                if (tot2>=20){
                                                    num=20;
                                                }
                                                else{
                                                    num=tot2
                                                }
                                            }
                                                for i in 0..<num{
                                                    print("inside FOR")
                                                    if let jsonObject = value as? [String: Any],
                                                       let embedded = jsonObject["_embedded"] as? [String: Any],
                                                       let events = embedded["events"] as? [[String: Any]],
                                                       let venuelist = events[i]["_embedded"] as? [String: Any],
                                                       let venues = venuelist["venues"] as? [[String: Any]],
                                                       let e_name = events[i]["name"] as? String,
                                                       let e_id = events[i]["id"] as? String,
                                                       let dates = events[i]["dates"] as? [String: Any],
                                                       let start = dates["start"] as? [String: Any],
                                                       let date = start["localDate"] as? String,
                                                       let time = start["localTime"] as? String,
                                                       let icon = events[i]["images"] as? [[String: Any]],
                                                       let icon2 = icon.first?["url"] as? String,
                                                       let venueName = venues.first?["name"] as? String {
                                                        print("Date: \(date)")
                                                        print("Time: \(time)")
                                                        print("Event Name: \(e_name)")
                                                        print("Venue Name: \(venueName)")
                                                        let s_event = Result(e_id: e_id, name: e_name, venue: venueName, date: date, time: time, icon: icon2)
                                                        self.evt.append(s_event)
                                                        print("s_event")
                                                    }
                                                }
                                            self.isLoading = false
                                            self.showResults = true
                                                print(self.evt)
                                            
                                        case .failure(let error):
                                            print(error)
                                        }
                                    }
                            }
                        case .failure(let error):
                            print(error)
                        }
                    }
            }
            
            
        }
            
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
    
