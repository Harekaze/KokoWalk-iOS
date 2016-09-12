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
	
	var gameLoop: Timer!
	var totalPoint: Int = 0

	private var characterNode: SKSpriteNode!
	private var suica: SKSpriteNode!
	
	let randomY = GKRandomDistribution(randomSource: GKARC4RandomSource(), lowestValue: -270, highestValue: 170)

	
	override func sceneDidLoad() {
		if characterNode != nil { return }
		self.characterNode = self.childNode(withName: "//ojisan") as? SKSpriteNode
		self.suica = self.childNode(withName: "//suica") as? SKSpriteNode
		
		self.gameLoop = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {
			timer in
			self.addSuica()
		})
		Timer.scheduledTimer(withTimeInterval: 125, repeats: false, block: {
			timer in
			self.gameLoop.invalidate()
		})
	}
	

	// MARK: - Frame update
	
	override func update(_ currentTime: TimeInterval) {
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
				SKAction.setTexture(SKTexture(imageNamed: "ojisan_middle")),
				SKAction.wait(forDuration: 0.3),
				SKAction.setTexture(SKTexture(imageNamed: "ojisan_def"))
				]))
			
			// Add attack point
			totalPoint += 5
			
			// Check first attack
			guard let created = suica.userData?["created"] as? Date else { continue }
			suica.userData?.removeObject(forKey: "created")
			suica.removeAction(forKey: "SuicaJoin")
			if suica.position.x < 0 {
				suica.run(SKAction.sequence([
					SKAction.init(named: "SuicaLeftOut")!,
					SKAction.removeFromParent()
					]))
			} else {
				suica.run(SKAction.sequence([
					SKAction.init(named: "SuicaRightOut")!,
					SKAction.removeFromParent()
					]))
			}
			
			// Add first attack point
			let point = (2 - DateInterval(start: created, end: Date()).duration) * 1000
			totalPoint += Int(point)
			
			return
		}
	}
	
	func addSuica() {
		if let suica = self.suica.copy() as? SKSpriteNode {
			suica.userData = ["created": Date()]
			suica.name = "activeSuica"
			
			if randomY.nextBool() {
				suica.position = CGPoint(x: -770, y: CGFloat(randomY.nextInt()))
				suica.run(SKAction.sequence([
					SKAction.init(named: "SuicaLeftIn")!,
					SKAction.init(named: "SuicaLeftOut")!,
					SKAction.removeFromParent()
					])
					, withKey: "SuicaJoin")
			} else {
				suica.position = CGPoint(x: 770, y: CGFloat(randomY.nextInt()))
				suica.run(SKAction.sequence([
					SKAction.init(named: "SuicaRightIn")!,
					SKAction.init(named: "SuicaRightOut")!,
					SKAction.removeFromParent()
					])
					, withKey: "SuicaJoin")
			}
			self.addChild(suica)
		}
	}
	
	// MARK: - Touch events
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			self.attack(position: touch.location(in: self))
		}
	}
	
}
