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
	
	var walls = [SKSpriteNode]()
	
	var wallsCatagory : UInt32 = 0x1 << 1
	var runnerCatagory : UInt32 = 0x1 << 2
	var barrierCatagory : UInt32 = 0x1 << 3
	
	var generateWallTimer : Timer?
	
	override func didMove(to view: SKView) {
		
		self.physicsWorld.contactDelegate = self
		
		self.leftBarrier = self.childNode(withName: "leftBarrier") as? SKSpriteNode
		self.rightBarrier = self.childNode(withName: "rightBarrier") as? SKSpriteNode
		
		self.leftBarrier?.physicsBody?.categoryBitMask = barrierCatagory
		self.rightBarrier?.physicsBody?.categoryBitMask = barrierCatagory
		self.leftBarrier?.physicsBody?.contactTestBitMask = runnerCatagory
		self.rightBarrier?.physicsBody?.contactTestBitMask = runnerCatagory
		self.leftBarrier?.physicsBody?.collisionBitMask = runnerCatagory
		self.rightBarrier?.physicsBody?.collisionBitMask = runnerCatagory
		
		
		self.runner = self.childNode(withName: "runner") as? SKSpriteNode
		
		self.runner?.physicsBody?.categoryBitMask = runnerCatagory
		self.runner?.physicsBody?.contactTestBitMask = wallsCatagory
		self.runner?.physicsBody?.collisionBitMask = barrierCatagory
		
		
		self.generateWallTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(createWall), userInfo: nil, repeats: true)
		
		
		
	}
	
	func createBarriers(){
		
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
		
		let breakPoint = generateRandomNumber(min: 5, max: Int(self.size.width) - 175)
		
		let leftWall = SKSpriteNode(color: .cyan, size: CGSize(width: 2 * breakPoint, height: 30))
		let rightWall = SKSpriteNode(color: .cyan, size: CGSize(width:2 * (self.size.width - (breakPoint + 170)), height: 30))
		
		leftWall.position = CGPoint(x:-(self.size.width/2), y: self.size.height/2)
		rightWall.position = CGPoint(x:self.size.width/2, y: self.size.height/2)
		
		leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
		rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
		
		leftWall.physicsBody?.categoryBitMask = wallsCatagory
		rightWall.physicsBody?.categoryBitMask = wallsCatagory
		leftWall.physicsBody?.collisionBitMask = 0x1 << 0
		rightWall.physicsBody?.collisionBitMask = 0x1 << 0
		leftWall.physicsBody?.affectedByGravity = false
		rightWall.physicsBody?.affectedByGravity = false
		leftWall.physicsBody?.allowsRotation = false
		rightWall.physicsBody?.allowsRotation = false
		
		self.addChild(leftWall)
		self.addChild(rightWall)
		
		self.walls.append(leftWall)
		let leftWallIndex = walls.count - 1
		
		self.walls.append(rightWall)
		let rightWallIndex = walls.count - 1
		
		
		
		
		let moveDown = SKAction.moveBy(x: 0, y: -self.size.height, duration: 5)
		
		var willMoveLeft = Bool.random()
		
		let differencePerTenthSec : CGFloat = 20
		
		let wallMoveTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
			
			if willMoveLeft{
				
				if leftWall.size.width > 5{
					
					rightWall.run(SKAction.resize(toWidth: rightWall.size.width + differencePerTenthSec, duration: 0.1))
					
					leftWall.run(SKAction.resize(toWidth: leftWall.size.width - differencePerTenthSec, duration: 0.1)){
						
						if leftWall.size.width <= 5{
							
							willMoveLeft = false
						}
					}
					
				}
				
			}else{
				
				if rightWall.size.width > 5{
					
					leftWall.run(SKAction.resize(toWidth: leftWall.size.width + differencePerTenthSec, duration: 0.1))
					
					rightWall.run(SKAction.resize(toWidth: rightWall.size.width - differencePerTenthSec, duration: 0.1)){
						
						if rightWall.size.width <= 5{
							
							willMoveLeft = true
						}
					}
				}
			}
		}
		
		leftWall.run(moveDown){
			
			leftWall.removeFromParent()
			
			wallMoveTimer.invalidate()
			
			self.walls.remove(at: leftWallIndex)
		}
		
		rightWall.run(moveDown){
			
			rightWall.removeFromParent()
			
			wallMoveTimer.invalidate()
			
			self.walls.remove(at: rightWallIndex)
		}
	}
	
	
	
	func generateRandomNumber(min: Int, max: Int) -> CGFloat {
		let randomNum = CGFloat(Int.random(in: min...max))
		
		return randomNum
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (self.scene?.isPaused)!{
			
			if let touchLocation = touches.first?.location(in: self){
				
				let nodesAtLocation = nodes(at: touchLocation)
				
				for node in nodesAtLocation{
					if node.name == "Play Button"{
						
						self.resetGame()
						
					}
				}
			}
			
		}else{
			
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
	}
	
	func endGame(){
		
		self.scene?.isPaused = true
		self.generateWallTimer?.invalidate()
		
		
		let gameOverLabel =  SKLabelNode(text: "Game Over!")
		gameOverLabel.name = "Game Over Label"
		gameOverLabel.position = CGPoint(x: 0, y: 0)
		gameOverLabel.fontSize = 120
		
		Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false) { (timer) in
			
			self.addChild(gameOverLabel)
			
		}
		
		
		let playButton = SKSpriteNode(imageNamed:"play-button.png")
		playButton.name = "Play Button"
		playButton.position = CGPoint(x: 0, y: -400)
		playButton.size = CGSize(width: 200, height: 200)
		
		self.addChild(playButton)
		
	}
	
	func resetGame(){
		
		let nodes = self.children
		
		for node in nodes{
			if node.physicsBody?.categoryBitMask == wallsCatagory || node.name == "Play Button" || node.name == "Game Over Label"{
				
				node.removeFromParent()
			}
		}
		
		self.scene?.isPaused = false
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
		
		if (contact.bodyB.categoryBitMask == runnerCatagory &&  contact.bodyB.categoryBitMask == wallsCatagory) || (contact.bodyA.categoryBitMask == runnerCatagory && contact.bodyB.categoryBitMask == wallsCatagory){
			
			endGame()
		}
	}
	
	override func didSimulatePhysics() {
		for wall in self.walls{
			
			wall.physicsBody = SKPhysicsBody(rectangleOf: wall.size)
			wall.physicsBody?.categoryBitMask = wallsCatagory
			wall.physicsBody?.collisionBitMask = 0x1 << 0
			wall.physicsBody?.affectedByGravity = false
			wall.physicsBody?.allowsRotation = false
		}
	}
}
