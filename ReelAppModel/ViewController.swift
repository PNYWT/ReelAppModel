//
//  ViewController.swift
//  ReelAppModel
//
//  Created by Dev on 25/9/2566 BE.
//

import UIKit

enum TypeShow{
    case AVController
    case AVLayer
}

class ViewController: UIViewController {

    @IBOutlet weak var btnShowAVControllerCell: UIButton!
    @IBOutlet weak var btnShowAVLayerCell: UIButton!
    @IBOutlet weak var cltvVideo: UICollectionView!
    private var dataVideo:[VideoModel] = []
    private let reuseIdentifierCltvVideo = "PlayerCell"
    private let reuseIdentifierCltvVideoLayer = "PlayerLayerCell"
    
    private var typeShow:TypeShow = .AVController
    
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
        
        btnShowAVLayerCell.addTarget(self, action: #selector(actionShowAVLayerCell), for: .touchUpInside)
        btnShowAVControllerCell.addTarget(self, action: #selector(actionShowAVControllerCell), for: .touchUpInside)
    }
    
    @objc func actionShowAVLayerCell(){
        typeShow = .AVLayer
        cltvVideo.reloadData()
    }
    
    @objc func actionShowAVControllerCell(){
        typeShow = .AVController
        cltvVideo.reloadData()
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
        cltvVideo.register(UINib(nibName: "PlayerLayerViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifierCltvVideoLayer)
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
        switch typeShow{
        case .AVController:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCltvVideo, for: indexPath) as! PlayerViewCell
            cell.configPlayer(model: self.dataVideo[indexPath.row])
            return cell
        case .AVLayer:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCltvVideo, for: indexPath) as! PlayerLayerViewCell
//            cell.configPlayer(model: self.dataVideo[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? PlayerViewCell{
            cell.stopPlayer()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch typeShow{
        case .AVController:
            if let cell = cell as? PlayerViewCell{
                cell.playerPlay()
            }
            break
        case .AVLayer:
            if let cell = cell as? PlayerLayerViewCell{
//                cell.playerPlay()
            }
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch typeShow{
        case .AVController:
            if let cell:PlayerViewCell = self.cltvVideo.cellForItem(at: indexPath) as? PlayerViewCell{
                cell.didselectToPlayorStop()
            }
            break
        case .AVLayer:
            break
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

