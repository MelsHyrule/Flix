//
//  NowPlayingViewController.swift
//  Flix
//
//  Created by Melody Ann Seda Marotte on 6/21/17.
//  Copyright © 2017 Melody Ann Seda Marotte. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource  {

    @IBOutlet weak var tableView: UITableView!
    var movies: [[String: Any]] = []                                //this movies is an array of dictionaries (like the movies below)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request =  URLRequest (url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration:  .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            //This will run when the network request returns
            //Here is where we 'parse' and get our data back
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                //print(dataDictionary)
                
                let movies = dataDictionary["results"] as! [[String: Any]]              //movies: an array of dictionaries
                self.movies = movies                                                    //makes the movies with the wide scope
                                                                                        //(from above, movies.self) have the same
                                                                                        //data as the movies from this smaller score
                //this for loop is for a test print
                /*
                for movie in movies {
                    let title = movie["title"] as! String
                    print(title)
                }
                */
                self.tableView.reloadData()
                //for updating the UI with the information once it returns from the server
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        //"MovieCell" : the identifies we gave the cell in the attributes inspector, its like a tag
        //as! MovieCell : type casts it to the class MovieCell instead of just a regular UITableViewCell
        let movie = movies[indexPath.row]                                               //this holds a single dictionary
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        //to get an image u need a base_url, a file_size and a file_path
        //  https://image.tmdb.org/t/p        /w500           /kqjL17yufvn9OVLyXYpvtyrFfak.jpg
        let posterPathString = movie["poster_path"] as! String          //poster path (for the image)
        let baseURLString = "https://image.tmdb.org/t/p/w500"           //has base URL and file size (w500)
        
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.posterimageView.af_setImage(withURL: posterURL)
        
        
        return cell
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    
    
    
}
