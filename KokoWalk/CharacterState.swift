/**
*
* CharacterState.swift
* KokoWalk
* Created by Yuki MIZUNO on 2016/09/10.
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

import UIKit
import GameplayKit

let randomX = GKRandomDistribution(randomSource: GKARC4RandomSource(), lowestValue: -250, highestValue: 250)
let randomY = GKRandomDistribution(randomSource: GKARC4RandomSource(), lowestValue: -350, highestValue: -100)

let actionImages: [String: [String]] = [
	"menu_item_koko": ["asisu", "hai", "koko_def", "koko_meshi", "koko_sensei", "koko_uta", "koko_zinb", "koko_zinbabue2", "kokomi_4", "kokotto", "naki_B1", "naki_B2", "orya", "ra_men", "sengen", "tettere_", "zinbabues"],
	"menu_item_mi": ["doitujin", "doitujin_", "doitujin2"],
	"menu_item_siro": ["siro_oko", "siro_same1", "siro_same2", "mayone-zu", "mayo2"],
	"menu_item_zona": ["zona_p"],
	"menu_item_irizaki": ["koufun", "may_p", "may_waki", "uttyae1", "uttyae2"],
	"menu_item_mike": ["mike_banana", "mike_boushi", "mike_hai"],
	"menu_item_maron": ["maron_maron", "motto_teyande", "teyande"]
		
]

let walk: [String: String] = [
	"menu_item_koko": "KokoWalk",
	"menu_item_mi": "MiWalk",
	"menu_item_siro": "SiroWalk",
	"menu_item_zona": "ZonaWalk",
	"menu_item_irizaki": "MayWalk",
	"menu_item_mike": "MikeWalk",
	"menu_item_maron": "MaronWalk"
]


class CharacterState: GKState {
	let characterNode: SKSpriteNode
	
	init(characterNode: SKSpriteNode) {
		self.characterNode = characterNode
	}
}

class JoiningState: CharacterState {
	override func update(deltaTime seconds: TimeInterval) {
		self.stateMachine?.enter(WalkingState.self)
		characterNode.run(SKAction.sequence([
			SKAction.wait(forDuration: 1.6),
			SKAction.run {
				self.stateMachine?.update(deltaTime: 1.6)
			},
			]))
	}
	
	override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass == WalkingState.self
	}
	
	override func didEnter(from previousState: GKState?) {
		let imageName = GKRandomSource().arrayByShufflingObjects(in: actionImages[characterNode.name!]!).first as! String
		characterNode.texture = SKTexture(imageNamed: imageName)
	}
}

class WalkingState: CharacterState {
	
	private var walkAction: SKAction!
	
	override init(characterNode: SKSpriteNode) {
		super.init(characterNode: characterNode)
		self.walkAction = SKAction.init(named: walk[characterNode.name!]!)!
	}

	override func update(deltaTime seconds: TimeInterval) {
		let point = CGPoint(x: CGFloat(randomX.nextInt()), y: CGFloat(randomY.nextInt()))
		let flip = (point.x - characterNode.position.x) * characterNode.xScale > 0

		characterNode.run(
			SKAction.sequence([
				walkAction,
				SKAction.run {
					self.stateMachine?.enter(StoppingState.self)
					self.stateMachine?.update(deltaTime: 1.6)
				}
				])
		)
		characterNode.run(SKAction.move(to: point, duration: 1.5))
		characterNode.run(SKAction.scaleX(by: flip ? -1 : 1, y: 1, duration: 0))
		characterNode.zPosition = point.y / -100

	}
	
	override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass == StoppingState.self
	}
}

class StoppingState: CharacterState {
	override func update(deltaTime seconds: TimeInterval) {
		characterNode.run(SKAction.sequence([
			SKAction.wait(forDuration: 1.6),
			SKAction.run {
				if randomX.nextInt() < 100 {
					self.stateMachine?.enter(WalkingState.self)
				} else {
					self.stateMachine?.enter(ActionState.self)
				}
				self.stateMachine?.update(deltaTime: 1.6)
			},
			]))
	}
}

class ActionState: CharacterState {
	
	private var actions = [String]()
	
	override func update(deltaTime seconds: TimeInterval) {
		if actions.isEmpty {
			actions = GKRandomSource().arrayByShufflingObjects(in: actionImages[characterNode.name!]!) as! [String]
		}
		characterNode.texture = SKTexture(imageNamed: actions.popLast()!)
		characterNode.run(SKAction.sequence([
			SKAction.wait(forDuration: 1.6),
			SKAction.run {
				self.stateMachine?.enter(WalkingState.self)
				self.stateMachine?.update(deltaTime: 1.6)
			},
			]))
	}
	
	override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass == WalkingState.self
	}
}
