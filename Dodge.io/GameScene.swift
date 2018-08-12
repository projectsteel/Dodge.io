//
//  GameScene.swift
//  Dodge.io
//
//  Created by Jamie Pickar on 8/11/18.
//  Copyright © 2018 Project Steel. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var leftWall : SKSpriteNode?
    var rightWall : SKSpriteNode?
    var runner : SKSpriteNode?
    
    var wallsCatagory : UInt32?
    var runnerCatagory : UInt32?
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.leftWall = self.childNode(withName: "leftWall") as? SKSpriteNode
        self.rightWall = self.childNode(withName: "rightWall") as? SKSpriteNode
        
        self.runner = self.childNode(withName: "runner") as? SKSpriteNode
    }
    
    func createWall() {
        
        print(Int(self.size.width))
        
        let breakPoint = generateRandomNumber(min: 5, max: Int(self.size.width * 2))
        
        print(breakPoint)
        
        let wall = SKSpriteNode(color: .cyan, size: CGSize(width: breakPoint, height: 5))
        
        wall.position = CGPoint(x:-(self.size.width/2) , y: self.size.height/2 - 20)
        
        self.addChild(wall)
        
        let moveUp = SKAction.moveBy(x: 0, y: -self.size.height, duration: 5)
        
        wall.run(moveUp){
            
            wall.removeFromParent()
        }
    }
    
    
    
    
    func generateRandomNumber(min: Int, max: Int) -> Int {
        let randomNum = Int.random(in: min...max)
        
        return randomNum
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        createWall()
        if let touch = touches.first{
            
            let point = touch.preciseLocation(in: self.view)
            
            let leftRect = CGRect(x: -self.size.width/4, y: 0, width: self.size.width/2, height: self.size.height)
            if leftRect.contains(point){
                
                runner?.physicsBody?.applyForce(CGVector(dx: -7000, dy: 0))
            }
            
            let rightRect = CGRect(x: self.size.width/4, y: 0, width: self.size.width/2, height: self.size.height)
            if rightRect.contains(point){
                
                
                runner?.physicsBody?.applyForce(CGVector(dx: 7000, dy: 0))
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let touch = touches.first{
            
            let point = touch.preciseLocation(in: self.view)
            
            let leftRect = CGRect(x: -self.size.width/4, y: 0, width: self.size.width/2, height: self.size.height)
            if leftRect.contains(point){
                
                runner?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                runner?.physicsBody?.applyForce(CGVector(dx: -20000, dy: 0))
            }
            
            let rightRect = CGRect(x: self.size.width/4, y: 0, width: self.size.width/2, height: self.size.height)
            if rightRect.contains(point){
                
                runner?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                runner?.physicsBody?.applyForce(CGVector(dx: 20000, dy: 0))
            }
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        runner?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
