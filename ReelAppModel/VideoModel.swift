//
//  VideoModel.swift
//  ReelAppModel
//
//  Created by Dev on 25/9/2566 BE.
//

import Foundation

struct VideoData: Decodable{
    let videoURL : [VideoModel]?
    
    private enum CodingKeys: String, CodingKey{
        case videoURL
    }
}

struct VideoModel:Decodable{
    let url:String?
}
