/**
*
* NaginataDojoViewController.swift
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

import UIKit
import SpriteKit
import GameplayKit

class NaginataDojoViewController: UIViewController {

	// MARK: Interface Builder actions

	@IBAction func handleExitButton(_ sender: UIButton) {
		dismiss(animated: false)
	}

	// MARK: View initialization

	override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOS 10.0, *) {
			if let scene = GKScene(fileNamed: "NaginataScene") {
				if let sceneNode = scene.rootNode as! NaginataScene? {
					sceneNode.scaleMode = .aspectFill

					if let view = self.view as! SKView? {
						view.presentScene(sceneNode)
						view.ignoresSiblingOrder = true
					}
				}
			}
		} else {
			if let scene = GameScene(fileNamed:"NaginataScene") {
				let skView = self.view as! SKView

				skView.ignoresSiblingOrder = true
				scene.scaleMode = .aspectFill

				skView.presentScene(scene)
			}
		}
	}

	// MARK: View appearing/disappearing

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		if let view = self.view as? SKView {
			view.removeFromSuperview()
		}
	}

	// MARK: Resource management

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: Device rotation

	override var shouldAutorotate: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .landscape
	}

	// MARK: Status bar

	override var prefersStatusBarHidden: Bool {
		return true
	}

	/*
	// MARK: Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
	}
	*/

}
