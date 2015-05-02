//
//  ViewController.swift
//  CacherNagoya
//
//  Created by katoy on 2015/04/26.
//  Copyright (c) 2015年 Youichi Kato. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // シーンの作成
        let scene = GameScene()

        // view を取り出して属性を設定
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true

        // シーンのサイズを view に合わせる
        scene.scaleMode = .AspectFill
        scene.size = skView.frame.size

        // view を表示する
        skView.presentScene(scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

