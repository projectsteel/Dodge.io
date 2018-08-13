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
    
    var leftBarrier : SKSpriteNode?
    var rightBarrier : SKSpriteNode?
    var runner : SKSpriteNode?
    
    var wallsCatagory : UInt32?
    var runnerCatagory : UInt32?
    
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        
        self.leftBarrier
 = self.childNode(withName: "leftWall") as? SKSpriteNode
        self.rightBarrier
 = self.childNode(withName: "rightWall") as? SKSpriteNode
        
        self.runner = self.childNode(withName: "runner") as? SKSpriteNode
    }
    
    func createWall() {
        
        let breakPoint = generateRandomNumber(min: 5, max: Int(self.size.width) - 150)
        
        let leftWall = SKSpriteNode(color: .cyan, size: CGSize(width: breakPoint, height: 5))
        
        let rightWall = SKSpriteNode(color: .cyan, size: CGSize(width: self.size.width - (breakPoint + 140), height: 5))
        
        leftWall.position = CGPoint(x:(-(self.size.width/2) + leftWall.size.width/2) , y: self.size.height/2)
        
        rightWall.position = CGPoint(x: (self.size.width/2) - rightWall.size.width/2, y: self.size.height/2)
        
        self.addChild(leftWall)
        
        self.addChild(rightWall)
        
        let moveDown = SKAction.moveBy(x: 0, y: -self.size.height, duration: 5)
        
        leftWall.run(moveDown){
            
            leftWall.removeFromParent()
        }
    
        rightWall.run(moveDown){
            
            rightWall.removeFromParent()
        }
    }
    
    
    
    
    func generateRandomNumber(min: Int, max: Int) -> CGFloat {
        let randomNum = CGFloat(Int.random(in: min...max))
        
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
