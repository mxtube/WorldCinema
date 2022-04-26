//
//  MovieInfo.swift
//  Cinema
//
//  Created by Кирилл Кузнецов on 25.04.2022.
//

import UIKit

class MovieInfo: UIViewController {
    
    var idMovie: String?

    override func viewWillAppear(_ animated: Bool) {
        print("Movie id:" + idMovie!)
    }

}
