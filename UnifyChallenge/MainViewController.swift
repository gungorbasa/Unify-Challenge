//
//  MainViewController2.swift
//  UnifyChallenge
//
//  Created by Gungor Basa on 5/28/17.
//  Copyright © 2017 Gungor Basa. All rights reserved.
//

import UIKit


class MainViewController: UIViewController {
    private var _imageNames = [String]()
    var imageNames: [String] {
        set {
            _imageNames = newValue
            self.collectionView.reloadData()
        }
        
        get {
            return _imageNames
        }
    }

    let reuseIdentifier = "secureImageCell"
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createUIImageFromData(data: Data) -> UIImage {
        if let capturedImage = UIImage(data: data) {
            return capturedImage
        }
        return UIImage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "secureCameraCapture" {
            if let vc = segue.destination as? PhotoTimerViewController {
                vc.delegate = self
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let secureData = SecureDataAdapter.retrieve(key: self.imageNames[indexPath.row])
        let image = createUIImageFromData(data: secureData!)
        cell.backgroundView = UIImageView(image: image)
        
        // Configure the cell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize = UIScreen.main.bounds
        var smallerSize = CGFloat()
        
        if screenSize.width < screenSize.height {
            smallerSize = screenSize.width
        } else {
            smallerSize = screenSize.height
        }
        
        return CGSize(width: (smallerSize/2)-15, height: (smallerSize/2)-15)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
}

extension MainViewController: ImageRetrieveProtocol {
    func didImagesTaken(names: [String]) {
        self.imageNames = names
    }
}




