//
//  Main.swift
//  Cinema
//
//  Created by Кирилл Кузнецов on 25.04.2022.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class Main: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var coverName: UILabel!
    @IBOutlet weak var movieCollection: UICollectionView!
    @IBOutlet var category: [UIButton]!
    @IBOutlet weak var lastMoviePoster: UIImageView!
    @IBOutlet weak var lastMoviePlay: UIButton!
    @IBOutlet weak var lastMovieName: UILabel!
    @IBOutlet weak var lastMovieTitle: UILabel!
    
    var movieId: String?
    var movieArray: [Movie] = []
    
    override func loadView() {
        super.loadView()
        requestLastMovie()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        coverName.text = ""
        requestCoverImage()
        gradientImageCoverMovie()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        isSelectedCategoryAction(category[0])
    }
    
    private func gradientImageCoverMovie() {
        let gradient = CAGradientLayer()
        let view = UIView(frame: cover.frame)
        gradient.frame = view.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 1.0]
        view.layer.insertSublayer(gradient, at: .max)
        view.alpha = 0.6
        cover.addSubview(view)
        cover.bringSubviewToFront(view)
    }
    
    @IBAction func coverMovieWatchAction(_ sender: UIButton) {
        performSegue(withIdentifier: "movieInfoSegue", sender: nil)
    }
    
    private func requestCoverImage() {
        AF.request(AppDelegate().baseUrl + "movies/cover", method: .get).response { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value!)
                let coverJson = json["foregroundImage"].stringValue
                let coverUrl: URL = URL(string: AppDelegate().baseUrlImage + coverJson)!
                let dataFromUrl: Data = try! Data(contentsOf: coverUrl)
                self.cover.image = UIImage(data: dataFromUrl)
                let idMovieJson = json["movieId"].stringValue
                self.requestMovie(by: idMovieJson)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func requestMovie(by filmId: String?) {
        AF.request(AppDelegate().baseUrl + "movies/\(filmId!)", method: .get).response { response in
            switch response.result {
            case .success(let value):
                self.movieId = filmId
                let json = JSON(value!)
                let movieNameJson = json["name"].stringValue
                self.coverName.text = movieNameJson
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func isSelectedCategoryAction(_ sender: UIButton) {
        let isSelected = sender.tag
        let category: String
        switch isSelected {
        case 0:
            category = "inTrend"
        case 1:
            category = "New"
        case 2:
            category = "forMe"
        default:
            category = "inTrend"
        }
        movieArray.removeAll()
        requestMovieList(of: category)
        isSelectedCategoryDesign(isSelected)
    }
    
    private func isSelectedCategoryDesign(_ selectedButton: Int) {
        for button in category {
            let frame = CGRect(x: 0, y: button.frame.size.height + 5, width: button.frame.size.width, height: 5)
            if button.tag == selectedButton {
                let borderBottom = UIView(frame: frame)
                borderBottom.backgroundColor = UIColor(named: "SegmentControlSelected")
                button.addSubview(borderBottom)
            } else {
                let borderBottom = UIView(frame: frame)
                borderBottom.backgroundColor = UIColor(named: "SegmentControlNotUse")
                button.addSubview(borderBottom)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieArray.count
    }
    
    private func requestMovieList(of name: String) {
        AF.request(AppDelegate().baseUrl + "/movies?filter=\(name)", method: .get).response { response in
            switch response.result {
            case .success(let value):
                self.parseMovieList(value!)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func parseMovieList(_ inJSON: Data) {
        let json = JSON(inJSON)
        for index in 0..<json.count {
            movieArray.append(
                Movie(
                    id: json[index]["movieId"].stringValue,
                    name: json[index]["name"].stringValue,
                    url: AppDelegate().baseUrlImage + json[index]["poster"].stringValue
                )
            )
        }
        movieCollection.reloadData()
    }
    
    private func requestLastMovie() {
        let token = UserDefaults.standard.integer(forKey: "token")
        let bearer: HTTPHeaders = ["Authorization": "Bearer \(token)"]
        AF.request(AppDelegate().baseUrl + "/usermovies?filter=lastView", method: .get, headers: bearer).response { response in
            switch response.result {
            case .success(let value):
                self.parseLastMovie(value!)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func parseLastMovie(_ inJSON: Data) {
        let json = JSON(inJSON)
        guard json.count >= 1 else { return hideLastMovie() }
        let movie = Movie(
            id: json[json.count-1]["movieId"].stringValue,
            name: json[json.count-1]["name"].stringValue,
            url: AppDelegate().baseUrlImage + json[json.count-1]["poster"].stringValue
        )
        lastMovieName.text = movie.name
        lastMoviePlay.tag = Int(movie.id)!
        let url: URL = URL(string: movie.url)!
        guard let imgData = try? Data(contentsOf: url) else { return }
        lastMoviePoster.image = UIImage(data: imgData)
    }
    
    private func hideLastMovie() {
        lastMovieTitle.removeFromSuperview()
        lastMoviePoster.removeFromSuperview()
        lastMovieName.removeFromSuperview()
        lastMoviePlay.removeFromSuperview()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellMovie = collectionView.dequeueReusableCell(withReuseIdentifier: "movieCell", for: indexPath) as! MovieCell
        cellMovie.layer.shouldRasterize = true
        cellMovie.layer.rasterizationScale = UIScreen.main.scale
        let urlString = movieArray[indexPath.row].url
        let url = URL(string: urlString)
        cellMovie.poster.kf.setImage(with: url)
        return cellMovie
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == movieCollection {
            movieId = movieArray[indexPath.row].id
            performSegue(withIdentifier: "movieInfoSegue", sender: nil)
        }
    }
    
    @IBAction func playLastMovie(_ sender: UIButton) {
        performSegue(withIdentifier: "movieInfoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieInfoSegue" {
            if let vc = segue.destination as? MovieInfo {
                vc.idMovie = movieId
            }
        }
    }
    
    
}
