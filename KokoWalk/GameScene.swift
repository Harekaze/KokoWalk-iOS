/**
*
* GameScene.swift
* KokoWalk
* Created by Yuki MIZUNO on 2016/09/04.
*
* Copyright (c) 2016, Harekaze
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice,
*    this list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice,
*    this list of conditions and the following disclaimer in the documentation
*     and/or other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors
*    may be used to endorse or promote products derived from this software
*    without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
* AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
* ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
* LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
* SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
* INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
* CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
* THE POSSIBILITY OF SUCH DAMAGE.
*/

import SpriteKit
import GameplayKit

class GameScene: SKScene {
	
	var entities = [GKEntity]()
	var graphs = [String : GKGraph]()
	
	private var lastUpdateTime : TimeInterval = 0
	private var label : SKLabelNode?
	private var spinnyNode : SKShapeNode?
	
	override func sceneDidLoad() {

		self.lastUpdateTime = 0
		
		// Get label node from scene and store it for use later
		self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
		if let label = self.label {
			label.alpha = 0.0
			label.run(SKAction.fadeIn(withDuration: 2.0))
		}
		
		// Create shape node to use during mouse interaction
		let w = (self.size.width + self.size.height) * 0.05
		self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
		
		if let spinnyNode = self.spinnyNode {
			spinnyNode.lineWidth = 2.5
			
			spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
			spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
											  SKAction.fadeOut(withDuration: 0.5),
											  SKAction.removeFromParent()]))
		}
	}
	
	// MARK: - Character addition
	
	func addCharacter(name: String) {
		let backgroundNode = SKSpriteNode(imageNamed: "asisu")
		backgroundNode.position = CGPoint(x: -215, y: 315)
		backgroundNode.name = "Charater"
		backgroundNode.scale(to: CGSize(width: 268, height: 508))
		backgroundNode.run(SKAction.init(named: "Join")!, withKey: "fadeInOut")
		self.addChild(backgroundNode)
	}
	
	
	// MARK: - Touch event
	
	func touchDown(atPoint pos : CGPoint) {
		if let n = self.spinnyNode?.copy() as! SKShapeNode? {
			n.position = pos
			n.strokeColor = SKColor.green
			self.addChild(n)
		}
	}
	
	func touchMoved(toPoint pos : CGPoint) {
		if let n = self.spinnyNode?.copy() as! SKShapeNode? {
			n.position = pos
			n.strokeColor = SKColor.blue
			self.addChild(n)
		}
	}
	
	func touchUp(atPoint pos : CGPoint) {
		if let n = self.spinnyNode?.copy() as! SKShapeNode? {
			n.position = pos
			n.strokeColor = SKColor.red
			self.addChild(n)
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let label = self.label {
			label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
		}
		
		for t in touches { self.touchDown(atPoint: t.location(in: self)) }
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
		
		// Initialize _lastUpdateTime if it has not already been
		if (self.lastUpdateTime == 0) {
			self.lastUpdateTime = currentTime
		}
		
		// Calculate time since last update
		let dt = currentTime - self.lastUpdateTime
		
		// Update entities
		for entity in self.entities {
			entity.update(deltaTime: dt)
		}
		
		self.lastUpdateTime = currentTime
	}
}
