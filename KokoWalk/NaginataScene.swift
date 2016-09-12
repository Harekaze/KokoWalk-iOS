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

	private var characterNode: SKSpriteNode!

	override func sceneDidLoad() {
		self.characterNode = self.childNode(withName: "//ojisan") as? SKSpriteNode
	}

	// MARK: - Frame update
	
	override func update(_ currentTime: TimeInterval) {
	}

	// MARK: - Action
	
	func attack(flip: Bool) {
		if flip {
			characterNode.run(SKAction.scaleX(by: -1, y: 1, duration: 0))
		}
		characterNode.run(SKAction.sequence([
			SKAction.setTexture(SKTexture(imageNamed: "ojisan_middle")),
			SKAction.wait(forDuration: 0.3),
			SKAction.setTexture(SKTexture(imageNamed: "ojisan_def"))
			]))
	}
	
	// MARK: - Touch events
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let flip = touch.location(in: self).x * characterNode.xScale > 0
			self.attack(flip: flip)
		}
	}
	
}
