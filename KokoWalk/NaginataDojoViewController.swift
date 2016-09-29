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
import Social
import GameKit

class NaginataDojoViewController: UIViewController, GKGameCenterControllerDelegate {

	// MARK: Private fields
	private lazy var localPlayer = GKLocalPlayer.localPlayer()
	private var leaderboardIdentifier = ""

	// MARK: Interface Builder actions

	@IBAction func handleExitButton(_ sender: UIButton) {
		dismiss(animated: false)
	}

	@IBAction func handleScoreButton(_ sender: UIButton) {
		let alertController = UIAlertController(title: "薙刀道場スコア", message: nil, preferredStyle: .actionSheet)
		let shareTwitter = UIAlertAction(title: "Twitterで共有", style: .default, handler:{
			_ in
			guard let view = self.view as! SKView? else { return }
			guard let naginataScene = view.scene as! NaginataScene? else { return }
			if let shareCompose = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
				UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
				view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
				let image = UIGraphicsGetImageFromCurrentImageContext()!
				UIGraphicsEndImageContext()
				shareCompose.add(image)
				shareCompose.add(URL(string: "https://harekaze.org/KokoWalk-iOS/")!)
				shareCompose.setInitialText("KokoWalk for iOSの薙刀道場で\(naginataScene.totalPoint)pt獲得しました！ #KokoWalk #NaginataScore")
				self.present(shareCompose, animated: true)
			} else {
				self.present(UIAlertController(title: "エラー", message: "Twitter共有がサポートされていません。", preferredStyle: .alert), animated: true)
			}
		})
		let gameCenter = UIAlertAction(title: "GameCenterで共有", style: .default, handler: {
			_ in
			guard let view = self.view as! SKView? else { return }
			guard let naginataScene = view.scene as! NaginataScene? else { return }

			if !self.localPlayer.isAuthenticated {
				self.localPlayer.authenticateHandler = {(viewController, error) in
					if let error = error {
						self.present(UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert), animated: true)
						return
					}

					if let viewController = viewController {
						self.present(viewController, animated: true, completion: nil)
					}

					if !self.localPlayer.isAuthenticated {
						self.present(UIAlertController(title: "エラー", message: "ログインに失敗しました。", preferredStyle: .alert), animated: true)
						return
					}

					self.localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifier, error) in
						if let error = error {
							self.present(UIAlertController(title: "エラー", message: error.localizedDescription, preferredStyle: .alert), animated: true)
						} else {
							self.leaderboardIdentifier = leaderboardIdentifier!
							let score = GKScore(leaderboardIdentifier: self.leaderboardIdentifier, player: self.localPlayer)
							score.value = Int64(naginataScene.totalPoint)
							GKScore.report([score])

							let gameCenterController = GKGameCenterViewController()
							gameCenterController.gameCenterDelegate = self
							gameCenterController.viewState = .leaderboards
							gameCenterController.leaderboardIdentifier = self.leaderboardIdentifier
							self.present(gameCenterController, animated: true)
						}
					})
				}
			} else {
				let score = GKScore(leaderboardIdentifier: self.leaderboardIdentifier, player: self.localPlayer)
				score.value = Int64(naginataScene.totalPoint)
				GKScore.report([score])

				let gameCenterController = GKGameCenterViewController()
				gameCenterController.gameCenterDelegate = self
				gameCenterController.viewState = .leaderboards
				gameCenterController.leaderboardIdentifier = self.leaderboardIdentifier
				self.present(gameCenterController, animated: true)
			}
		})

		let cancel = UIAlertAction(title: "cancel", style: .cancel)
		alertController.addAction(shareTwitter)
		alertController.addAction(gameCenter)
		alertController.addAction(cancel)
		present(alertController, animated: true)
	}

	// MARK: GameCenter

	func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
		gameCenterViewController.dismiss(animated: true)
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
			if let sceneNode = GameScene(fileNamed:"NaginataScene") {
				sceneNode.scaleMode = .aspectFill

				if let view = self.view as! SKView? {
					view.presentScene(sceneNode)
					view.ignoresSiblingOrder = true
				}
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

}
