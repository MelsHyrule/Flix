//
//  NowPlayingViewController.swift
//  Flix
//
//  Created by Melody Ann Seda Marotte on 6/21/17.
//  Copyright © 2017 Melody Ann Seda Marotte. All rights reserved.
//

import UIKit
import AlamofireImage

class NowPlayingViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate  {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies: [[String: Any]] = []            //all data collected
    var filteredDatas: [[String: Any]] = []      //all data kept by search bar
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start the activity indicator
        activityIndicator.startAnimating()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        tableView.dataSource = self
        searchBar.delegate = self
        filteredDatas = movies
        
        fetchMovies()
        
        // Stop the activity indicator
        // Hides automatically if "Hides When Stopped" is enabled
        activityIndicator.stopAnimating()
    }
    
    func didPullToRefresh (_ refreshControl: UIRefreshControl) {
        fetchMovies()
    }
    
    func fetchMovies() {
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
                self.filteredDatas = movies
                
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
                
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return movies.count
        return filteredDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        //"MovieCell" : the identifies we gave the cell in the attributes inspector, its like a tag
        //as! MovieCell : type casts it to the class MovieCell instead of just a regular UITableViewCell
        
        
        
        //let movie = movies[indexPath.row]                                             //this holds a single dictionary
        let movie = filteredDatas[indexPath.row]
        //this is using the data that has been filtered by the search bar
        
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
        
        let backgroundView = UIView()
        let brightRed = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        backgroundView.backgroundColor = brightRed
        cell.selectedBackgroundView = backgroundView
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let indexPath = tableView.indexPath(for: cell){
            //let movie = movies[indexPath.row]
            let movie = filteredDatas[indexPath.row]
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movie
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // This method updates filteredDatas based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        filteredDatas = searchText.isEmpty ? movies : movies.filter {
            (item: [String:Any]) -> Bool in
            return (item["title"] as! String).range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
