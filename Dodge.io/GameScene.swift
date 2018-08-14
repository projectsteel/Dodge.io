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
	
	var wallsCatagory : UInt32 = 0x1 << 1
	var runnerCatagory : UInt32 = 0x1 << 2
	var barrierCatagory : UInt32 = 0x1 << 3
	
	var generateWallTimer : Timer?
	
	override func didMove(to view: SKView) {
		
		self.physicsWorld.contactDelegate = self
		
		self.leftBarrier = self.childNode(withName: "leftWall") as? SKSpriteNode
		self.rightBarrier = self.childNode(withName: "rightWall") as? SKSpriteNode
		
		self.runner = self.childNode(withName: "runner") as? SKSpriteNode
		
		self.runner?.physicsBody?.categoryBitMask = runnerCatagory
		self.runner?.physicsBody?.contactTestBitMask = wallsCatagory
		self.runner?.physicsBody?.collisionBitMask = barrierCatagory
		
		
		self.generateWallTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(createWall), userInfo: nil, repeats: true)
		
		let runner = self.runner!
		
		let upBarrier = SKSpriteNode(color: .clear, size: CGSize(width: self.size.width, height: 0.5))
		let downBarrier = SKSpriteNode(color: .clear, size: CGSize(width: self.size.width, height: 0.5))
		
		upBarrier.position = CGPoint(x: 0, y: runner.position.y + runner.size.height/2 + 0.5 )
		downBarrier.position = CGPoint(x: 0, y: runner.position.y - runner.size.height/2 + 0.5)
		
		upBarrier.physicsBody = SKPhysicsBody(rectangleOf: upBarrier.size)
		downBarrier.physicsBody = SKPhysicsBody(rectangleOf: downBarrier.size)
		
		upBarrier.physicsBody?.pinned = true
		downBarrier.physicsBody?.pinned = true
		
		upBarrier.physicsBody?.categoryBitMask = barrierCatagory
		downBarrier.physicsBody?.categoryBitMask = barrierCatagory
		upBarrier.physicsBody?.contactTestBitMask = runnerCatagory
		downBarrier.physicsBody?.contactTestBitMask = runnerCatagory
		upBarrier.physicsBody?.allowsRotation = false
		downBarrier.physicsBody?.allowsRotation = false
		upBarrier.physicsBody?.affectedByGravity = false
		downBarrier.physicsBody?.affectedByGravity = false
		upBarrier.physicsBody?.mass = 10
		downBarrier.physicsBody?.mass = 10
		upBarrier.physicsBody?.restitution = 0
		downBarrier.physicsBody?.restitution = 0
		
		self.addChild(upBarrier)
		self.addChild(downBarrier)
		
	}
	
	@objc func createWall() {
		
		let breakPoint = generateRandomNumber(min: 5, max: Int(self.size.width) - 150)
		
		let leftWall = SKSpriteNode(color: .cyan, size: CGSize(width: breakPoint, height: 5))
		let rightWall = SKSpriteNode(color: .cyan, size: CGSize(width: self.size.width - (breakPoint + 140), height: 5))
		
		leftWall.position = CGPoint(x:(-(self.size.width/2) + leftWall.size.width/2) , y: self.size.height/2)
		rightWall.position = CGPoint(x: (self.size.width/2) - rightWall.size.width/2, y: self.size.height/2)
		
		leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
		rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
		
		leftWall.physicsBody?.categoryBitMask = wallsCatagory
		rightWall.physicsBody?.categoryBitMask = wallsCatagory
		leftWall.physicsBody?.collisionBitMask = 0x1 << 0
		rightWall.physicsBody?.collisionBitMask = 0x1 << 0
		leftWall.physicsBody?.affectedByGravity = false
		rightWall.physicsBody?.affectedByGravity = false
		
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
	
	func didBegin(_ contact: SKPhysicsContact) {
		
		
	}
	
}
