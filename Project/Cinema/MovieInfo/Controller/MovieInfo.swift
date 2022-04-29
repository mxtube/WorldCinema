//
//  MovieInfo.swift
//  Cinema
//
//  Created by Кирилл Кузнецов on 25.04.2022.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import AVFoundation
import AVKit

class MovieInfo: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var idMovie: String?
    
    @IBOutlet weak var movieName: UILabel!
    @IBOutlet weak var ratingAge: UILabel!
    @IBOutlet weak var posterMovie: UIImageView!
    @IBOutlet weak var aboutMovie: UILabel!
    @IBOutlet weak var tagCollection: UICollectionView!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var episodeCollection: UICollectionView!
    @IBOutlet weak var watchPreview: UIImageView!
    @IBOutlet weak var watchButton: UIButton!
    @IBOutlet weak var watchTitle: UILabel!
    
    var tagArray: [String] = []
    var imageArray: [String] = []
    var episodeArray: [Episode] = []
    var defaultEpisode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestMovie(by: idMovie)
        requestEpisode(by: idMovie)
        gradientImageCoverMovie(posterMovie)
    }
    
    private func gradientImageCoverMovie(_ image: UIImageView) {
        let gradient = CAGradientLayer()
        let view = UIView(frame: image.frame)
        gradient.frame = view.frame
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.0, 0.6]
        view.layer.insertSublayer(gradient, at: .max)
        view.alpha = 0.6
        image.addSubview(view)
        image.bringSubviewToFront(view)
    }
    
    private func requestEpisode(by filmId: String?) {
        AF.request(AppDelegate().baseUrl + "movies/\(filmId!)/episodes", method: .get).response { response in
            switch response.result {
            case .success(let value):
                self.parseEpisodes(value!)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func parseEpisodes(_ inJson: Data) {
        let json = JSON(inJson)
        print(json)
        for episodeIndex in 0..<json.count {
            episodeArray.append(
                Episode(
                    image: AppDelegate().baseUrlVideo + json[episodeIndex]["preview"].stringValue,
                    name: json[episodeIndex]["name"].stringValue,
                    description: json[episodeIndex]["description"].stringValue,
                    year: json[episodeIndex]["year"].stringValue
                )
            )
            episodeCollection.reloadData()
        }
        let previewImage = json[0]["preview"].stringValue
        if previewImage == "" {
            watchButton.removeFromSuperview()
            watchPreview.removeFromSuperview()
            watchTitle.removeFromSuperview()
        } else {
            defaultEpisode = AppDelegate().baseUrlVideo + previewImage
            watchPreview.image = imagePreview(from: AppDelegate().baseUrlVideo + previewImage, in: 0.10)
        }
    }
    
    private func requestMovie(by filmId: String?) {
        AF.request(AppDelegate().baseUrl + "movies/\(filmId!)", method: .get).response { response in
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
        print(json)
        movieName.text = json["name"].stringValue
        let age = json["age"].stringValue
        ratingAge.text = age + "+"
        ageDesign(age)
        let imageUrl = URL(string: AppDelegate().baseUrlImage + json["poster"].stringValue)
        if let data = try? Data(contentsOf: imageUrl!) { posterMovie.image = UIImage(data: data) }
        for tagIndex in 0..<json["tags"].count {
            tagArray.append(json["tags"][tagIndex]["tagName"].stringValue)
            tagCollection.reloadData()
        }
        aboutMovie.text = json["description"].stringValue
        for imageIndex in 0..<json["images"].count {
            imageArray.append(AppDelegate().baseUrlImage + json["images"][imageIndex].stringValue)
            imageCollection.reloadData()
        }
    }
    
    private func ageDesign(_ age: String) {
        let converted = Int(age)
        switch converted {
        case 18:
            ratingAge.textColor = UIColor(named: age)
        case 16:
            ratingAge.textColor = UIColor(named: age)
        case 12:
            ratingAge.textColor = UIColor(named: age)
        case 6:
            ratingAge.textColor = UIColor(named: age)
        case 0:
            ratingAge.textColor = UIColor(named: age)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imageCollection {
            return imageArray.count
        } else if collectionView == episodeCollection {
            return episodeArray.count
        }
        return tagArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == imageCollection {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
            let url = URL(string: imageArray[indexPath.row])
            cell.image.kf.setImage(with: url)
            return cell
            
        } else if collectionView == episodeCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "episodeCell", for: indexPath) as! EpisodeCell
            
            cell.episodeImage.image = imagePreview(from: episodeArray[indexPath.row].image, in: 0.20)
            cell.episodeName.text = episodeArray[indexPath.row].name
            cell.episodeDescription.text = episodeArray[indexPath.row].description
            cell.episodeYear.text = episodeArray[indexPath.row].year
            
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCell", for: indexPath) as! TagCell
        cell.tagLabel.setTitle(tagArray[indexPath.row], for: .disabled)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Clicked")
        if collectionView == episodeCollection {
            playVideo(from: episodeArray[indexPath.row].image)
        }
    }
    
    private func playVideo(from Uri: String) {
        let urlString = Uri.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let videoURL = URL(string: urlString!)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func imagePreview(from moviePath: String, in seconds: Double) -> UIImage? {
        let urlString = moviePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlString!)
        let timestamp = CMTime(seconds: seconds, preferredTimescale: 60)
        let asset = AVURLAsset(url: url!)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        guard let imageRef = try? generator.copyCGImage(at: timestamp, actualTime: nil) else { return nil }
        return UIImage(cgImage: imageRef)
    }
    
    @IBAction func playVideoAction(_ sender: UIButton) {
        playVideo(from: defaultEpisode)
    }
    
}
