//
//  GameScene.swift
//  CacherNagoya
//
//  Created by katoy on 2015/04/27.
//  Copyright (c) 2015年 Youichi Kato. All rights reserved.
//

// See  http://www.shuwasystem.co.jp/support/7980html/4055.html
//      > 書籍： Sprite Kit iPhone 2Dゲームプログラミング 3 章
// 
// BGM: 
//    Copy and paste the following text into your video's credits:
//    "Gymnopedie No. 1" Kevin MacLeod (incompetech.com)
//    Licensed under Creative Commons: By Attribution 3.0
//    http://creativecommons.org/licenses/by/3.0/

import Foundation
import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {

    var isPlaying = false
    var goods = Array<SKSpriteNode>()
    var audioPlayer = AVAudioPlayer()

    var spriteScale : CGFloat = 0.2  // スプライトの大きさの倍率

    var bowlDuration = 1.0           // どんぶりの移動にかかる時間(秒)
    var fallInterval = 3.0           // 落下間隔時間(秒)
    var bowlY : CGFloat = 10         // どんぶりの 位置の Y 座標
    let lowestShapeHeigh = 2         // 落下判定用シェイプの高さ

    var timer : NSTimer?             // 落下用タイマー
    var lowestShape : SKShapeNode?   // 落下判定用シェイプ
    var bowl : SKSpriteNode?         // どんぶり用スプライト

    var score = 0                    // スコア
    var scoreLabel: SKLabelNode?     // スコア用ラベル
    // 名古屋名物のスコア
    var scoreList = [100, 200, 300, 500, 800, 1000, 1500]

    override func didMoveToView(view: SKView) {
        initGame()
        startGame()
    }

    // ゲームの初期設定
    func initGame() {
        // 下方向への重力を設定
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: -2.0)
        // 衝突判定を有効にする
        self.physicsWorld.contactDelegate = self

        // 背景画像のスプライトを配置
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        background.size = self.size
        self.addChild(background)

        // 落下判定用シェイプ
        let lowestShape = SKShapeNode(rectOfSize: CGSize(width: Int(self.size.width * 3), height: lowestShapeHeigh))
        lowestShape.position = CGPoint(x: Int(self.frame.midX), y: (-1) * lowestShapeHeigh )  // 画面外に配置
        // シェイプの大きさで物理シミュレーションを行う
        let physicsBody = SKPhysicsBody(rectangleOfSize: lowestShape.frame.size)
        physicsBody.dynamic = false                 // 落下しないように固定

        physicsBody.contactTestBitMask = 0x1 << 1   // 名古屋名物との衝突を検知する
        lowestShape.physicsBody = physicsBody
        self.addChild(lowestShape)
        self.lowestShape = lowestShape

        // スコア用ラベル
        let scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.position = CGPoint(x: self.size.width * 0.92, y: self.size.height * 0.78)
        scoreLabel.text = "¥0"
        scoreLabel.fontSize = 32
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right   // 右寄せ
        scoreLabel.fontColor = UIColor.greenColor()
        self.addChild(scoreLabel)
        self.scoreLabel = scoreLabel

        // どんぶり用スプライト
        let bowlTexture = SKTexture(imageNamed: "bowl")
        let bowl = SKSpriteNode(texture: bowlTexture)
        bowlY = bowl.size.height * 0.5 * spriteScale
        bowl.position = CGPoint(x: self.frame.midX, y: bowlY)
        bowl.size = CGSize(width: bowlTexture.size().width * spriteScale, height: bowlTexture.size().height * spriteScale)

        // どんぶりのテクスチャの不透過部分の形状で物理シミュレーションを行う
        bowl.physicsBody = SKPhysicsBody(texture: bowlTexture, size: bowl.size)
        bowl.physicsBody?.dynamic = false           // 落下しないように固定

        self.addChild(bowl)
        self.bowl = bowl

        // 音楽再生のための設定
        var bgm = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Gymnopedie No 1", ofType: "mp3")!)
        audioPlayer = AVAudioPlayer(contentsOfURL: bgm, error: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.numberOfLoops = -1
        audioPlayer.play()
    }

    // ゲームの開始設定
    func startGame() {
        // 画面上の物品を削除する
        for i in goods {
            i.removeFromParent()
        }
        goods = []

        // どんぶりの位置をリセット
        bowl!.position = CGPoint(x: self.frame.midX, y: bowlY)

        // タイマーを作成し一定時間ごとに fallNagoyaSpecialty メソッドを呼ぶ
        self.timer = NSTimer.scheduledTimerWithTimeInterval(fallInterval, target: self, selector: "fallNagoyaSpecialty", userInfo: nil, repeats: true)

        isPlaying = true  // ゲーム状態をプレー中にする。
    }

    // 名古屋名物を出現させて、落下を開始するメソッド
    func fallNagoyaSpecialty() {
        // 0〜6のランダムな整数を発生させる
        let index = Int(arc4random_uniform(7))
        let texture = SKTexture(imageNamed: "\(index)") // 選択された番号のテクスチャを読み込む

        // テクスチャからスプライトを生成する
        let sprite = SKSpriteNode(texture: texture)
        sprite.position = CGPoint(x: self.frame.midX, y: self.size.height)
        sprite.size = CGSize(width: texture.size().width * spriteScale, height: texture.size().height * spriteScale)

        // テクスチャの不透過部分の形状で物理シミュレーションを行う
        sprite.physicsBody = SKPhysicsBody(texture: texture, size: sprite.size)
        sprite.physicsBody?.contactTestBitMask = 0x1 << 1   // 落下判定用シェイプとの衝突を検知する
        self.addChild(sprite)
        goods.append(sprite)

        // 落下した物に応じてスコアを加算する
        self.score += self.scoreList[index]
        // 金額のラベルを更新
        self.scoreLabel?.text = "¥\(self.score)"
    }

    // タッチ開始時に呼ばれるメソッド
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            // シーン上のタッチされた位置を取得する
            let location = touch.locationInNode(self)
            if isPlaying {
                // タッチされた位置にノードを水平移動させる
                let action = SKAction.moveTo(CGPoint(x: location.x, y: bowlY), duration: bowlDuration)
                self.bowl?.runAction(action)
            } else {
                startGame()   // ゲームリスタート
            }
        }
    }

    // 指を動かしたときに呼ばれるメソッド
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            // シーン上のタッチされた位置を取得する
            let location = touch.locationInNode(self)
            // タッチされた位置にノードを水平移動させる
            let action = SKAction.moveTo(CGPoint(x: location.x, y: bowlY), duration: bowlDuration)
            self.bowl?.runAction(action)
        }
    }

    // 衝突が発生したときに呼ばれるメソッド
    func didBeginContact(contact: SKPhysicsContact) {
        // 衝突した一方が落下判定用シェイプだったら
        if contact.bodyA.node == self.lowestShape || contact.bodyB.node == self.lowestShape {
            // アクションを停止させる
            //self.paused = true
            // タイマーを破棄する
            self.timer?.invalidate()

            // ゲームオーバースプライトを表示
            let sprite = SKSpriteNode(imageNamed: "gameover")
            sprite.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.5)
            self.addChild(sprite)
            self.goods.append(sprite)

            isPlaying = false   // ゲーム状態を停止にする。
        }
    }
}
