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

	var stateMachines = [GKStateMachine]()
	var characterNodes = [SKSpriteNode]()
	var graphs = [String : GKGraph]()
	dynamic var clockMode = false

	private var characterNode: SKSpriteNode?
	private var dateLabel: SKLabelNode!
	private var timeLabel: SKLabelNode!
	private var secondsLabel: SKLabelNode!
	private var secondsDateFormatter: DateFormatter!

	override func sceneDidLoad() {
		if #available(iOS 10.0, *) {
			self.characterNode = SKSpriteNode(imageNamed: "asisu")

			if let characterNode = self.characterNode {
				characterNode.position = CGPoint(x: -215, y: 315)
				characterNode.name = "Charater"
				characterNode.scale(to: CGSize(width: 268, height: 508))
				characterNode.zPosition = 4
				characterNode.run(SKAction.init(named: "Join")!, withKey: "join")
			}

			Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true, block: {
				timer in
				for stateMachine in self.stateMachines {
					if stateMachine.currentState is JoiningState {
						stateMachine.update(deltaTime: 0)
					}
				}
			})
		}

		self.dateLabel = self.childNode(withName: "//date") as? SKLabelNode
		self.timeLabel = self.childNode(withName: "//time") as? SKLabelNode
		self.secondsLabel = self.childNode(withName: "//seconds") as? SKLabelNode
		self.secondsDateFormatter = DateFormatter()
		self.secondsDateFormatter.dateFormat = "ss"
	}

	// MARK: - FOR IOS9 SUPPORT

	override func didMove(to view: SKView) {
		super.didMove(to: view)
		if #available(iOS 10.0, *) {} else {
			self.characterNode = SKSpriteNode(imageNamed: "asisu")

			if let characterNode = self.characterNode {
				characterNode.position = CGPoint(x: -215, y: 315)
				characterNode.name = "Charater"
				characterNode.setScale(268 / characterNode.size.width)
				characterNode.zPosition = 4
				characterNode.run(SKAction.init(named: "Join")!, withKey: "join")
			}

			Timer.scheduledTimer(timeInterval: 1.6, target: self, selector: #selector(loop), userInfo: nil, repeats: true)
			self.dateLabel = self.childNode(withName: "//date") as? SKLabelNode
			self.timeLabel = self.childNode(withName: "//time") as? SKLabelNode
			self.secondsLabel = self.childNode(withName: "//seconds") as? SKLabelNode
			self.secondsDateFormatter = DateFormatter()
			self.secondsDateFormatter.dateFormat = "ss"
		}
	}

	func loop() {
		for stateMachine in self.stateMachines {
			if stateMachine.currentState is JoiningState {
				stateMachine.update(deltaTime: 0)
			}
		}
	}


	// MARK: - Character addition

	func addCharacter(name: String) {
		if characterNodes.count > 20 {
			var minZPosition:CGFloat = 10
			var index: Int = 0
			for (i, characterNode) in characterNodes.enumerated() {
				if characterNode.zPosition == min(minZPosition, characterNode.zPosition) {
					minZPosition = characterNode.zPosition
					index = i
				}
			}
			characterNodes[index].removeFromParent()
			characterNodes.remove(at: index)
			stateMachines.remove(at: index)
		}
		let characterNode = self.characterNode?.copy() as! SKSpriteNode
		characterNode.name = name
		let stateMachine = GKStateMachine(states: [
			JoiningState(characterNode: characterNode),
			WalkingState(characterNode: characterNode),
			StoppingState(characterNode: characterNode),
			ActionState(characterNode: characterNode),
			]
		)
		stateMachine.enter(JoiningState.self)
		self.stateMachines.append(stateMachine)
		self.characterNodes.append(characterNode)

		self.addChild(characterNode)
	}

	func washimoiruzo(afterBlock: @escaping () -> Void) {
		let characterNode = SKSpriteNode(imageNamed: "washimoikou2")
		characterNode.position = CGPoint(x: 550, y: -350)
		characterNode.name = "Washimoiruzo"
		if #available(iOS 10.0, *) {
			characterNode.scale(to: CGSize(width: 268, height: 508))
		} else {
			characterNode.setScale(268 / characterNode.size.width)
		}
		characterNode.zPosition = 4
		characterNode.run(SKAction.sequence([
			SKAction.init(named: "Washimoiruzo")!,
			SKAction.removeFromParent(),
			SKAction.run(afterBlock)
			]), withKey: "Washimoiruzo")
		self.addChild(characterNode)
	}

	// MARK: - Character deletion

	func clearAll() {
		for characterNode in self.characterNodes {
			characterNode.removeFromParent()
		}
		characterNodes.removeAll()
		stateMachines.removeAll()
	}

	// MARK: - Frame update

	override func update(_ currentTime: TimeInterval) {
		let now = Date()
		self.dateLabel.text = DateFormatter.localizedString(from: now, dateStyle: .medium, timeStyle: .none)
		self.timeLabel.text = DateFormatter.localizedString(from: now, dateStyle: .none, timeStyle: .short)
		self.secondsLabel.text = self.secondsDateFormatter.string(from: now)
	}

	// MARK: - Touch events

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.dateLabel.isHidden = self.clockMode
		self.timeLabel.isHidden = self.clockMode
		self.secondsLabel.isHidden = self.clockMode
		self.clockMode = !self.clockMode
	}
}
