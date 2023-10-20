//
//  ViewController.swift
//  ReelAppModel
//
//  Created by Dev on 25/9/2566 BE.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cltvVideo: UICollectionView!
    private var dataVideo:[VideoModel] = []
    private let reuseIdentifierCltvVideo = "PlayerCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configCltv()
        
        self.loadDataView { loadSuccess in
            if let succ = loadSuccess{
                self.dataVideo = succ
            }
            
            DispatchQueue.main.async {
                self.cltvVideo.reloadData()
            }
        }
    }
    
    private func configCltv(){
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        cltvVideo.collectionViewLayout = layout
        
        cltvVideo.delegate = self
        cltvVideo.dataSource = self
        cltvVideo.register(UINib(nibName: "PlayerViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierCltvVideo)
        cltvVideo.isPagingEnabled = true
        cltvVideo.isDirectionalLockEnabled = true
    }
    
    private func loadDataView(completionLoad:@escaping(_ loadSuccess:[VideoModel]?)->Void) ->Void{
        guard let filePath = Bundle.main.path(forResource: "VideoURLData", ofType: "json") else {
            print("Not found JsonVideoURL.json")
            return
        }

        guard let  data = try? String(contentsOfFile: filePath).data(using: .utf8) else{
            print("Data not found in json")
            return
        }
        do {
            let jsonData = try JSONDecoder().decode(VideoData.self, from: data)
            completionLoad(jsonData.videoURL)
        } catch {
            print("Something went wrong")
            completionLoad(nil)
        }
    }
}

extension ViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataVideo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCltvVideo, for: indexPath) as! PlayerViewCell
        cell.configPlayer(model: self.dataVideo[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PlayerViewCell{
            cell.stopPlayer()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PlayerViewCell{
            cell.playerPlay()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell:PlayerViewCell = self.cltvVideo.cellForItem(at: indexPath) as? PlayerViewCell{
            cell.didselectToPlayorStop()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in cltvVideo.visibleCells {
            (cell as? PlayerViewCell)?.stopPlayer()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in cltvVideo.visibleCells {
            (cell as? PlayerViewCell)?.playerPlay()
        }
    }
}

