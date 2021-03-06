/**
*
* NaginataScene.swift
* KokoWalk
* Created by Yuki MIZUNO on 2016/09/12.
*
* Copyright (c) 2016-2017, Harekaze
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
import UIKit

class NaginataScene: SKScene {

	var totalPoint: Int = 0
	var isFinished: Bool = false
	var fullCombo: Bool {
		return isFinished && suicaCount == comboCount
	}

	private var characterNode: SKSpriteNode!
	private var suicaNode: SKSpriteNode!
	private var countdownLabel: SKLabelNode!
	private var pointLabel: SKLabelNode!

	private var startDate: Date!
	private var lastUpdateTime: TimeInterval = 0
	private var waitingTime: TimeInterval = 0
	private var suicaInterval: TimeInterval = 2
	private var suicaCount: Int = 0
	private var comboCount: Int = 0
	var maxComboCount: Int = 0

	private let fluctuation = GKRandomDistribution(randomSource: GKARC4RandomSource(), lowestValue: -200, highestValue: 100)

	private var impactFeedbackGenerator: Any?

	let randomY = GKRandomDistribution(randomSource: GKARC4RandomSource(), lowestValue: -270, highestValue: 170)

	var doujouMode: String!
	// TODO: create class for this state control
	let actionImages: [String: [String]] = [
		"menu_item_mariko_doujou": ["marikoojisan_doujou", "marikoojisan_tyudan", "marikoojisan_joudan"],
		"menu_item_mei_doujou": ["may_waki", "may_uttyae1", "may_uttyae2"],
		"menu_item_koko_doujou": ["koko_naki_B1", "koko_shot1", "koko_shot2"],
		//"menu_item_koko_doujou_hard": [],
		"menu_item_oyabun_doujou": ["oyabun", "oyabun2", "oyabun3"],
	]

	override func sceneDidLoad() {
		if #available(iOS 10.0, *) {
			super.sceneDidLoad()
			impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
			if let impactFeedbackGenerator = impactFeedbackGenerator as? UIImpactFeedbackGenerator {
				impactFeedbackGenerator.prepare()
			}
		}
		self.characterNode = self.childNode(withName: "//ojisan") as? SKSpriteNode
		self.suicaNode = self.childNode(withName: "//suica") as? SKSpriteNode
		self.countdownLabel = self.childNode(withName: "//countdown") as? SKLabelNode
		self.pointLabel = self.childNode(withName: "//point") as? SKLabelNode
		self.startDate = Date()
	}

	// MARK: FOR IOS9 SUPPORT

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		self.characterNode = self.childNode(withName: "//ojisan") as? SKSpriteNode
		// Set character image
		self.characterNode.texture = SKTexture(imageNamed: actionImages[self.doujouMode]![0])
		if self.doujouMode != "menu_item_mariko_doujou" {
			characterNode.size = CGSize(width: 252, height: 477.75)
			characterNode.position = CGPoint(x: 0, y: -113.125)
		}
		self.suicaNode = self.childNode(withName: "//suica") as? SKSpriteNode
		self.countdownLabel = self.childNode(withName: "//countdown") as? SKLabelNode
		self.pointLabel = self.childNode(withName: "//point") as? SKLabelNode
		self.startDate = Date()
	}
	// MARK: Frame update

	override func update(_ currentTime: TimeInterval) {
		if self.lastUpdateTime == 0 {
			self.lastUpdateTime = currentTime
		}

		let time: Int
		if #available(iOS 10.0, *) {
			time = Int(120 - round(DateInterval(start: self.startDate, end: Date()).duration))
		} else {
			time = Int(120 - round(Date().timeIntervalSince(self.startDate)))
		}

		if time < 0 {
			if self.children.filter({$0.name == "activeSuica"}).count == 0 {
				self.characterNode.texture = SKTexture(imageNamed: actionImages[self.doujouMode]![0])
				self.isPaused = true
				self.isFinished = true
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

	// MARK: Action

	func attack(position: CGPoint) {
		for child in self.children {
			// Check node whether suica
			guard let suica = child as? SKSpriteNode else { continue }
			guard let name = suica.name else { continue }
			if name != "activeSuica" { continue }

			// Check attack position
			if hypot(position.x - suica.position.x, position.y - suica.position.y) > suica.size.width / 2 {
				continue
			}

			// Attack feedback
			if #available(iOS 10.0, *) {
				if let impactFeedbackGenerator = impactFeedbackGenerator as? UIImpactFeedbackGenerator {
					impactFeedbackGenerator.impactOccurred()
				}
			}
			
			// Attack action
			let flip = position.x * characterNode.xScale > 0
			if flip {
				characterNode.run(SKAction.scaleX(by: -1, y: 1, duration: 0))
			}
			characterNode.run(SKAction.sequence([
				randomY.nextBool() ? SKAction.setTexture(SKTexture(imageNamed: actionImages[self.doujouMode]![1])) : SKAction.setTexture(SKTexture(imageNamed: actionImages[self.doujouMode]![2])),
				SKAction.wait(forDuration: 0.3),
				SKAction.setTexture(SKTexture(imageNamed: actionImages[self.doujouMode]![0]))
				]))

			// Add attack point
			guard let created = suica.userData?["created"] as? Date else { continue }
			let point: Double
			if #available(iOS 10.0, *) {
				point = (1.6 - DateInterval(start: created, end: Date()).duration) * (1000 + Double(comboCount * 10))
			} else {
				point = (1.6 - Date().timeIntervalSince(created)) * (1000 + Double(comboCount * 10))
			}
			totalPoint += Int(point)

			// Check first attack
			if suica.action(forKey: "SuicaJoin") == nil { continue }
			suica.removeAction(forKey: "SuicaJoin")

			comboCount += 1
			maxComboCount = max(maxComboCount, comboCount)

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
					self.pointLabel.text = String(format: "%dpt (ver 3.1)", arguments: [self.totalPoint])
				}
				])
			)
		}
	}

	func addSuica() {
		if let suica = self.suicaNode.copy() as? SKSpriteNode {
			suica.userData = ["created": Date()]
			suica.name = "activeSuica"
			self.suicaCount += 1

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
				SKAction.run({
					self.comboCount = 0
				}),
				SKAction.removeFromParent()
				])
				, withKey: "SuicaJoin")

			self.addChild(suica)
		}
	}

	func updateInterval() {
		switch totalPoint {
		case 0..<10000:
			suicaInterval = 1.8
		case 10000..<20000:
			suicaInterval = 1.6
		case 20000..<40000:
			suicaInterval = 1.4
		case 40000..<60000:
			suicaInterval = 1.0
		case 60000..<120000:
			suicaInterval = 0.9
		case 120000..<200000:
			suicaInterval = 0.85
		case 200000..<560000:
			suicaInterval = 0.8 - TimeInterval(totalPoint / 2000000)
		default:
			suicaInterval = 0.56
		}
		suicaInterval += TimeInterval(fluctuation.nextInt() / 1000)
	}

	// MARK: Touch events

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			self.attack(position: touch.location(in: self))
		}
	}

}
