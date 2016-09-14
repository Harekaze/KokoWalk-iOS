/**
*
* NaginataScene.swift
* KokoWalk
* Created by Yuki MIZUNO on 2016/09/12.
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

class NaginataScene: SKScene {
	
	var totalPoint: Int = 0

	private var characterNode: SKSpriteNode!
	private var suicaNode: SKSpriteNode!
	private var countdownLabel: SKLabelNode!
	private var pointLabel: SKLabelNode!
	
	private var startDate: Date!
	private var lastUpdateTime: TimeInterval = 0
	private var waitingTime: TimeInterval = 0
	private var suicaInterval: TimeInterval = 2
	
	let randomY = GKRandomDistribution(randomSource: GKARC4RandomSource(), lowestValue: -270, highestValue: 170)

	
	override func sceneDidLoad() {
		self.characterNode = self.childNode(withName: "//ojisan") as? SKSpriteNode
		self.suicaNode = self.childNode(withName: "//suica") as? SKSpriteNode
		self.countdownLabel = self.childNode(withName: "//countdown") as? SKLabelNode
		self.pointLabel = self.childNode(withName: "//point") as? SKLabelNode
		self.startDate = Date()
	}

	// MARK: - Frame update
	
	override func update(_ currentTime: TimeInterval) {
		if self.lastUpdateTime == 0 {
			self.lastUpdateTime = currentTime
		}
		
		let time = Int(120 - round(DateInterval(start: self.startDate, end: Date()).duration))
		if time < 0 {
			if self.children.filter({$0.name == "activeSuica"}).count == 0 {
				characterNode.texture = SKTexture(imageNamed: "ojisan_def")
				self.isPaused = true
			}
			return
		}
		self.countdownLabel.text = String(format: "%02d:%02d", arguments: [time / 60, time % 60])

		let dt = currentTime - self.lastUpdateTime
		self.waitingTime += dt
		
		if waitingTime >= suicaInterval {
			self.waitingTime = 0
			self.addSuica()
			self.updateInterval()
		}
		
		self.lastUpdateTime = currentTime
	}

	// MARK: - Action

	func attack(position: CGPoint) {
		for child in self.children {
			// Check node whether suica
			guard let suica = child as? SKSpriteNode else { continue }
			guard let name = suica.name else { continue }
			if name != "activeSuica" { continue }
		
			// Check attack direction
			if position.x * suica.position.x < 0 { continue }
			
			// Attack action
			let flip = position.x * characterNode.xScale > 0
			if flip {
				characterNode.run(SKAction.scaleX(by: -1, y: 1, duration: 0))
			}
			characterNode.run(SKAction.sequence([
				randomY.nextBool() ? SKAction.setTexture(SKTexture(imageNamed: "ojisan_middle")) : SKAction.setTexture(SKTexture(imageNamed: "ojisan_up")),
				SKAction.wait(forDuration: 0.3),
				SKAction.setTexture(SKTexture(imageNamed: "ojisan_def"))
				]))
			
			// Add attack point
			totalPoint += 5
			
			// Check first attack
			guard let created = suica.userData?["created"] as? Date else { continue }
			suica.userData?.removeObject(forKey: "created")
			suica.removeAction(forKey: "SuicaJoin")
			let direction: String
			if suica.position.x < 0 {
				direction = "Left"
			} else {
				direction = "Right"
			}
			suica.run(SKAction.sequence([
				SKAction.init(named: "Suica\(direction)Out")!,
				SKAction.removeFromParent(),
				SKAction.run {
					self.pointLabel.text = String(format: "%dpt (ver 1.0)", arguments: [self.totalPoint])
				}
				])
			)
			
			// Add first attack point
			let point = (1.6 - DateInterval(start: created, end: Date()).duration) * 1000
			totalPoint += Int(point)
			
			return
		}
	}
	
	func addSuica() {
		if let suica = self.suicaNode.copy() as? SKSpriteNode {
			suica.userData = ["created": Date()]
			suica.name = "activeSuica"
			
			let direction: String
			let xSide: CGFloat
			if randomY.nextBool() {
				direction = "Left"
				xSide = -1
			} else {
				direction = "Right"
				xSide = 1
			}

			suica.position = CGPoint(x: xSide * 770, y: CGFloat(randomY.nextInt()))
			suica.run(SKAction.sequence([
				SKAction.init(named: "Suica\(direction)In")!,
				SKAction.init(named: "Suica\(direction)Out")!,
				SKAction.removeFromParent()
				])
				, withKey: "SuicaJoin")
			
			self.addChild(suica)
		}
	}
	
	func updateInterval() {
		switch totalPoint {
		case 0..<40000:
			suicaInterval = 2.0
		case 40000..<60000:
			suicaInterval = 1.8
		case 60000..<80000:
			suicaInterval = 1.6
		case 80000..<100000:
			suicaInterval = 1.4
		default:
			suicaInterval = 1.2
		}
	}
	
	// MARK: - Touch events
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			self.attack(position: touch.location(in: self))
		}
	}
	
}
