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
	
	var superNode = SKNode()
	
	var leftBarrier : SKNode?
	var rightBarrier : SKNode?
	var runner : SKSpriteNode?
	
	var wallsCatagory : UInt32 = 0x1 << 1
	var runnerCatagory : UInt32 = 0x1 << 2
	var barrierCatagory : UInt32 = 0x1 << 3
	
	var timeOfLastWallGeneration : TimeInterval = 0.0
	var timeOfLastWallUpdate : TimeInterval = 0.0
	var timeOfLastWallReaping :  TimeInterval = 0.0
	var timerOfLastWallSideMotion : TimeInterval = 0.0
	var wallss : [[SKSpriteNode]] = []
	var wallssWillMoveLeft : [Bool] = []
	
	var lastTouchPointX : CGFloat?
	var slowingDistance : CGFloat?
	
	var score : Int = 0
	var scoreLabel : SKLabelNode?
	
	var userHasPaused : Bool = false
	var systemHasPaused : Bool = false
	
	
	override func didMove(to view: SKView) {
		self.isPaused = true
		self.addChild(superNode)
		
		NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(willTerminate), name: UIApplication.willTerminateNotification, object: nil)
		
		self.physicsWorld.contactDelegate = self
		
		self.leftBarrier = self.childNode(withName: "leftBarrier")
		self.rightBarrier = self.childNode(withName: "rightBarrier")
		
		self.leftBarrier?.physicsBody?.categoryBitMask = barrierCatagory
		self.rightBarrier?.physicsBody?.categoryBitMask = barrierCatagory
		self.leftBarrier?.physicsBody?.contactTestBitMask = runnerCatagory
		self.rightBarrier?.physicsBody?.contactTestBitMask = runnerCatagory
		self.leftBarrier?.physicsBody?.collisionBitMask = runnerCatagory
		self.rightBarrier?.physicsBody?.collisionBitMask = runnerCatagory
		
		
		self.runner = self.childNode(withName: "runner") as? SKSpriteNode
		
		self.runner?.alpha = 0.0
		self.runner?.physicsBody?.categoryBitMask = runnerCatagory
		self.runner?.physicsBody?.contactTestBitMask = wallsCatagory
		self.runner?.physicsBody?.collisionBitMask = barrierCatagory
		
		self.slowingDistance = runner!.size.width/5
		
		
		let scoreLabel = SKLabelNode(text: "0")
		scoreLabel.fontSize = 90
		scoreLabel.position = CGPoint(x: 0, y: self.frame.height/2 - scoreLabel.frame.height * 2 - 8)
		
		self.scoreLabel = scoreLabel
		self.addChild(self.scoreLabel!)
		
		self.setupGame()
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
		
		let breakPoint = generateRandomNumber(min: 5, max: self.size.width - (gapDistance + minimumWallWidth))
		
		let leftWall = SKSpriteNode(color: .cyan, size: CGSize(width: 2 * breakPoint, height: 30))
		let rightWall = SKSpriteNode(color: .cyan, size: CGSize(width:2 * (self.size.width - (breakPoint + CGFloat(gapDistance))), height: 30))
		
		leftWall.name = "leftWall"
		rightWall.name = "rightWall"
		
		leftWall.position = CGPoint(x:-(self.size.width/2), y: self.size.height/2)
		rightWall.position = CGPoint(x:self.size.width/2, y: self.size.height/2)
		
		leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
		rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
		
		leftWall.physicsBody?.categoryBitMask = self.wallsCatagory
		rightWall.physicsBody?.categoryBitMask = self.wallsCatagory
		leftWall.physicsBody?.contactTestBitMask = self.runnerCatagory
		rightWall.physicsBody?.contactTestBitMask = self.runnerCatagory
		leftWall.physicsBody?.collisionBitMask = 0x1 << 0
		rightWall.physicsBody?.collisionBitMask = 0x1 << 0
		leftWall.physicsBody?.affectedByGravity = false
		rightWall.physicsBody?.affectedByGravity = false
		leftWall.physicsBody?.allowsRotation = false
		rightWall.physicsBody?.allowsRotation = false
		
		self.superNode.addChild(leftWall)
		self.superNode.addChild(rightWall)
		
		let willMoveLeft = Bool.random()
		
		self.wallssWillMoveLeft.append(willMoveLeft)
		self.wallss.append([leftWall, rightWall])
		
		
		self.setupWallMotion(leftWall: leftWall, rightWall: rightWall, willMoveLeft: !willMoveLeft, isRecovingExistingWalls: false)
		
	}
	
	func setupWallMotion(leftWall: SKSpriteNode, rightWall: SKSpriteNode, willMoveLeft: Bool, isRecovingExistingWalls: Bool){
		if willMoveLeft{
			
			leftWall.run(SKAction.resize(toWidth: CGFloat(minimumWallWidth * 2) , duration: secsToMoveGap))
			
			rightWall.run(SKAction.resize(toWidth:(self.size.width - CGFloat((minimumWallWidth + gapDistance))) * 2 , duration: secsToMoveGap))
			
			
		}else{
			
			leftWall.run(SKAction.resize(toWidth: (self.size.width - CGFloat((minimumWallWidth + gapDistance))) * 2, duration: secsToMoveGap))
			
			rightWall.run(SKAction.resize(toWidth: CGFloat(minimumWallWidth * 2), duration: secsToMoveGap))
			
		}
		
		if !isRecovingExistingWalls{
			
			let moveDown = SKAction.moveBy(x: 0, y: -self.size.height - leftWall.frame.height, duration: wallMoveDownDuration)
			
			leftWall.run(moveDown){
				
				leftWall.removeFromParent()
				
			}
			
			rightWall.run(moveDown){
				
				rightWall.removeFromParent()
				
			}
		}
	}
	
	func updateWallsPhysicsBodies(nodes: [SKSpriteNode]){
		
		for node in nodes{
			
			node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
			
			
			node.physicsBody?.categoryBitMask = self.wallsCatagory
			node.physicsBody?.contactTestBitMask = self.runnerCatagory
			node.physicsBody?.collisionBitMask = 0x1 << 0
			node.physicsBody?.affectedByGravity = false
			node.physicsBody?.allowsRotation = false
			
		}
	}
	
	func checkForNewPoints(node: SKSpriteNode){
		if let runner = self.runner{
			
			if ((node.position.y - runner.position.y) < 5) && ((node.position.y - runner.position.y) > -5) {
				
				self.score+=1
				
				//wallMoveDownDuration -= 0.05
				
				self.updateScoreLabelToScore()
			}
		}
	}
	
	func generateRandomNumber(min: CGFloat, max: CGFloat) -> CGFloat {
		let randomNum = CGFloat(CGFloat.random(in: min...max))
		
		return randomNum
	}
	
	func updateScoreLabelToScore(){
		
		if !self.isPaused && !self.superNode.isPaused{
			if let scoreLabel = self.scoreLabel{
				
				let currentTotal = UserDefaults.standard.integer(forKey: "currentTotal")
				UserDefaults.standard.set(currentTotal + 1, forKey: "currentTotal")
				
				let currentRecord = UserDefaults.standard.integer(forKey: "currentRecord")
				if score > currentRecord{
					UserDefaults.standard.set(score, forKey: "currentRecord")
				}
				
				scoreLabel.text = String(describing: score)
			}
		}
	}
	
	
	func setupGame(){
		
		self.isPaused = true
		self.systemHasPaused = true
		
		if let scoreLabel = self.scoreLabel{
			scoreLabel.text = ""
		}
		
		
		let playButton = SKSpriteNode(imageNamed:"play-button.png")
		playButton.name = "Play Button"
		playButton.position = CGPoint(x: 0, y: -300)
		playButton.size = CGSize(width: 150, height: 150)
		
		self.superNode.addChild(playButton)
		
		let bestScoreLabel = SKLabelNode()
		bestScoreLabel.name = "Best Score Label"
		bestScoreLabel.position = CGPoint(x: 0, y: 0)
		bestScoreLabel.fontSize = 70
		bestScoreLabel.text = "High Score: \(UserDefaults.standard.integer(forKey: "currentRecord"))"
		
		self.superNode.addChild(bestScoreLabel)
		
		let gameOverLabel =  SKLabelNode()
		
		gameOverLabel.text = "Dodge.io"
		gameOverLabel.name = "Game Over Label"
		gameOverLabel.position = CGPoint(x: 0, y: bestScoreLabel.fontSize/2 + 140)
		gameOverLabel.fontSize = 140
		
		sleep(UInt32(0.01))
		
		self.superNode.addChild(gameOverLabel)
		
	}
	
	func endGame(){
		
		//so it doesnt register a colsion everysecond and make with into a loop
		self.runner?.physicsBody?.categoryBitMask = 0x0 << 0
		self.systemHasPaused = true
		self.superNode.isPaused = true
		self.runner?.physicsBody?.pinned = true
		
		self.runner?.run(SKAction.fadeOut(withDuration: 0.75)){
			self.isPaused = true
			self.runner?.removeAllActions()
			self.runner?.physicsBody?.pinned = false
			self.superNode.isPaused = false
		}
		
		let playButton = SKSpriteNode(imageNamed:"play-button.png")
		playButton.name = "Play Button"
		playButton.position = CGPoint(x: 0, y: -300)
		playButton.size = CGSize(width: 150, height: 150)
		
		self.superNode.addChild(playButton)
		
		let bestScoreLabel = SKLabelNode()
		bestScoreLabel.name = "Best Score Label"
		bestScoreLabel.position = CGPoint(x: 0, y: 0)
		bestScoreLabel.fontSize = 70
		bestScoreLabel.text = "Score: \(score)"
		
		self.superNode.addChild(bestScoreLabel)
		
		let gameOverLabel =  SKLabelNode()
		gameOverLabel.text = "Game Over!"
		gameOverLabel.name = "Game Over Label"
		gameOverLabel.position = CGPoint(x: 0, y: bestScoreLabel.fontSize/2 + 140)
		gameOverLabel.fontSize = 140
		
		if let scoreLabel = self.scoreLabel{
			scoreLabel.text = ""
		}
		
		sleep(UInt32(0.01))
		
		self.superNode.addChild(gameOverLabel)
		
	}
	
	func resetGame(){
		superNode.removeAllChildren()
		
		self.runner?.run(SKAction.fadeIn(withDuration: 0.25))
		
		self.runner?.physicsBody?.pinned = false
		self.runner?.physicsBody?.categoryBitMask = runnerCatagory
		self.runner?.position.x = 0
		
		self.score = 0
		self.updateScoreLabelToScore()
		restoreSpeed()
		
		self.systemHasPaused = false
		self.scene?.isPaused = false
	}
	
	func pauseGame(){
		
		self.scene?.isPaused = true
		self.userHasPaused = true
		
		let gameOverLabel =  SKLabelNode()
		
		gameOverLabel.text = "Paused"
		gameOverLabel.name = "Game Over Label"
		gameOverLabel.position = CGPoint(x: 0, y: 0)
		gameOverLabel.fontSize = 120
		
		self.superNode.addChild(gameOverLabel)
		
		let playButton = SKSpriteNode(imageNamed:"play-button.png")
		playButton.name = "Play Button"
		playButton.position = CGPoint(x: 0, y: -300)
		playButton.size = CGSize(width: 150, height: 150)
		
		self.superNode.addChild(playButton)
		
		
	}
	
	func unpauseGame(){
		
		var leftWalls : [SKSpriteNode] = []
		var rightWalls : [SKSpriteNode] = []
		var walls : [[SKSpriteNode]] = []
		
		let nodes = self.superNode.children
		
		for node in nodes{
			if node.name == "Play Button" || node.name == "Game Over Label"{
				
				node.removeFromParent()
			}else if node.name == "leftWall"{
				leftWalls.append(node as! SKSpriteNode)
			}else if node.name == "rightWall"{
				rightWalls.append(node as! SKSpriteNode)
			}
		}
		
		for leftWall in leftWalls{
			for rightWall in rightWalls{
				if leftWall.position.y == rightWall.position.y{
					walls.append([leftWall, rightWall])
					break
				}
			}
		}
		
		
		self.scene?.isPaused = false
		self.reSetupWallMotion(wallss: walls)
		self.userHasPaused = false
		
	}
	
	
	func reSetupWallMotion(wallss: [[SKSpriteNode]]){
		
		for walls in wallss{
			
			let leftWall = walls[0]
			let rightWall = walls[1]
			
			self.setupWallMotion(leftWall: leftWall, rightWall: rightWall, willMoveLeft: Bool.random(), isRecovingExistingWalls: true)
		}
	}
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		if self.isPaused{
			
			if let touchLocation = touches.first?.location(in: self){
				
				let nodesAtLocation = nodes(at: touchLocation)
				
				for node in nodesAtLocation{
					if node.name == "Play Button"{
						if self.userHasPaused{
							
							self.unpauseGame()
							
						}else{
							
							
							self.resetGame()
						}
					}
				}
			}
			
		}else{
			
			if let runner = self.runner, let touchPointX = touches.first?.previousLocation(in: runner.parent!).x{
				
				self.lastTouchPointX = touchPointX
				
				if touchPointX > runner.position.x {
					
					runner.physicsBody?.velocity = CGVector(dx: runnerStandardSpeed, dy: 0)
					
					
				}else if touchPointX < runner.position.x{
					
					runner.physicsBody?.velocity = CGVector(dx: -runnerStandardSpeed, dy: 0)
					
				}
			}
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		touchesBegan(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		runner?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		
		if (contact.bodyB.categoryBitMask == runnerCatagory &&  contact.bodyA.categoryBitMask == wallsCatagory) || (contact.bodyA.categoryBitMask ==
			
			runnerCatagory && contact.bodyB.categoryBitMask == wallsCatagory){
			
			self.endGame()
		}
	}
	
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
		
		if let runner = self.runner, let lastTouchPointX = self.lastTouchPointX, let slowingDistance = self.slowingDistance, let runnerPhysicsBody = self.runner?.physicsBody, runner.physicsBody?.velocity.dx != 0{
			
			if lastTouchPointX - runner.position.x <= slowingDistance && lastTouchPointX - runner.position.x >= -slowingDistance{
				
				runnerPhysicsBody.velocity.dx = -(runnerStandardSpeed/slowingDistance) * (lastTouchPointX.distance(to: runner.position.x))
				
			}
		}
		
		if (currentTime - self.timeOfLastWallGeneration) >  wallMoveDownDuration/2.5{
			
			createWall()
			
			self.timeOfLastWallGeneration = currentTime
			
		}
		
		if (currentTime - self.timeOfLastWallUpdate) > 0.04{
			
			for walls in wallss{
				
				self.updateWallsPhysicsBodies(nodes: walls)
				
				self.checkForNewPoints(node: walls[0])
				
			}
			self.timeOfLastWallUpdate = currentTime
		}
		
		if (currentTime - self.timeOfLastWallReaping) > 0.2{
			var i = 0
			
			for walls in wallss{
				
				if (walls[0].position.y + (walls[0].size.width/2)) < -(self.size.height/2) && (walls[1].position.y + (walls[1].size.width/2)) < -(self.size.height/2){
					
					for wall in walls{
						wall.removeFromParent()
					}
					
					wallss.remove(at: i)
					wallssWillMoveLeft.remove(at: i)
				}
				
				i+=1
				
			}
			self.timeOfLastWallReaping = currentTime
		}
		
		var i = 0
		
		for walls in self.wallss{
			
			if wallssWillMoveLeft[i]{
				
				if walls[1].size.width == CGFloat(minimumWallWidth * 2){
					
					walls[0].run(SKAction.resize(toWidth: CGFloat(minimumWallWidth * 2) , duration: secsToMoveGap))
					
					walls[1].run(SKAction.resize(toWidth:(self.size.width - CGFloat((minimumWallWidth + gapDistance))) * 2 , duration: secsToMoveGap))
					
					self.wallssWillMoveLeft[i] = false
					
					
				}
				
			}else{
				
				if walls[0].size.width == CGFloat(minimumWallWidth * 2){
					
					walls[0].run(SKAction.resize(toWidth: (self.size.width - CGFloat((minimumWallWidth + gapDistance))) * 2, duration: secsToMoveGap))
					
					walls[1].run(SKAction.resize(toWidth: CGFloat(minimumWallWidth * 2), duration: secsToMoveGap))
					
					
					self.wallssWillMoveLeft[i] = true
					
				}
			}
			
			i+=1
		}
		
		
	}
	
	
	
	func appDidSuspend(){
		
		if !self.userHasPaused && !systemHasPaused{
			self.pauseGame()
		}
	}
	
	func appDidRenenstate(){
		
		self.isPaused = true
		
	}
	
	@objc func willResignActive() {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
		
		self.appDidSuspend()
	}
	
	@objc func didEnterBackground() {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		
		self.appDidSuspend()
	}
	
	@objc func willEnterForeground() {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
		
	}
	
	@objc func didBecomeActive() {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		self.appDidRenenstate()
		
	}
	
	@objc func willTerminate() {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
}
