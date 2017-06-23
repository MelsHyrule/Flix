//
//  SuperheroViewController.swift
//  Flix
//
//  Created by Melody Ann Seda Marotte on 6/23/17.
//  Copyright © 2017 Melody Ann Seda Marotte. All rights reserved.
//

import UIKit

class SuperheroViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionViewController: UICollectionView!
    var movies: [[String: Any]] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionViewController.dataSource = self //as! UICollectionViewDataSource
        
        let layout = collectionViewController.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let cellsPerLine: CGFloat  = 2
        let interItemSpacingTotal = layout.minimumInteritemSpacing * (cellsPerLine - 1)
        let width = (collectionViewController.frame.size.width - interItemSpacingTotal) / cellsPerLine
        layout.itemSize = CGSize(width: width, height: width * 3 / 2)
        
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        
        fetchMovies()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as! ColorCell
        let movie = movies[indexPath.row]
        
        let posterPathString = movie["poster_path"] as! String
        let baseURLString = "https://image.tmdb.org/t/p/w500"
        
        let posterURL = URL(string: baseURLString + posterPathString)!
        cell.SuperposterImageView.af_setImage(withURL: posterURL)
        
        return cell
    }

    
    func fetchMovies() {
        let url = URL(string: "https://api.themoviedb.org/3/movie/297762/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request =  URLRequest (url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration:  .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let movies = dataDictionary["results"] as! [[String: Any]]
                self.movies = movies
                self.collectionViewController.reloadData()
            }
        }
        task.resume()
    }
}
