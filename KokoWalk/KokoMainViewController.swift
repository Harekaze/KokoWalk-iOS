/**
*
* KokoMainViewController.swift
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

import UIKit
import SpriteKit
import GameplayKit

class KokoMainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	// MARK: Private constant values
	private let dataSource: [String] = [
		"menu_item_koko",
		"menu_item_mi",
		"menu_item_irizaki",
		"menu_item_maron",
		"menu_item_mike",
		"menu_item_siro",
		"menu_item_zona",
		"menu_item_mariko_doujou",
		"menu_item_mei_doujou",
		"menu_item_koko_doujou",
//		"menu_item_koko_doujou_hard",
//		"menu_item_oyabun_doujou",
		"menu_item_nop",
		"menu_item_nop",
		"menu_item_nop",
	]

	// MARK: Private instance fields
	private var gameScene: GameScene!
	private var doujouMode: String!

	// MARK: Interface Builder outlets

	@IBOutlet weak var sceneView: SKView!
	@IBOutlet weak var characterModeCollectionView: UICollectionView!
	@IBOutlet weak var washimoiruzoButton: UIButton!
	@IBOutlet weak var clearButton: UIButton!

	// MARK: Interface Builder actions

	@IBAction func handleClearButton(_ sender: UIButton) {
		self.gameScene.clearAll()
	}

	@IBAction func handleWashimoiruzo(_ sender: UIButton) {
		sender.isEnabled = false
		self.gameScene.washimoiruzo(afterBlock: {
			sender.isEnabled = true
		})
	}

	// MARK: View initialization

	override func viewDidLoad() {
		super.viewDidLoad()

		self.characterModeCollectionView.delegate = self

		if #available(iOS 10.0, *) {
			if let scene = GKScene(fileNamed: "GameScene") {
				if let sceneNode = scene.rootNode as! GameScene? {
					self.gameScene = sceneNode

					sceneNode.scaleMode = .aspectFill

					sceneView.presentScene(sceneNode)
					sceneView.ignoresSiblingOrder = true

					gameScene.addObserver(self, forKeyPath: "clockMode", options: [.new], context: nil)
				}
			}
		} else {
			if let sceneNode = GameScene(fileNamed:"GameScene") {
				self.gameScene = sceneNode

				sceneNode.scaleMode = .aspectFill

				sceneView.presentScene(sceneNode)
				sceneView.ignoresSiblingOrder = true

				gameScene.addObserver(self, forKeyPath: "clockMode", options: [.new], context: nil)
			}
		}

	}

	// MARK: View appearing/disappearing

	override func viewWillAppear(_ animated: Bool) {
		UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
		super.viewWillAppear(animated)
		sceneView.isPaused = false
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated)
		sceneView.isPaused = true
	}

	// MARK: Resource management

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	// MARK: Observer

	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "clockMode" {
			clearButton.isHidden = gameScene.clockMode
			washimoiruzoButton.alpha = gameScene.clockMode ? 0 : 1
		}
	}

	// MARK: Device rotation

	override var shouldAutorotate: Bool {
		return true
	}

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return sceneView == nil || sceneView.isPaused ? .allButUpsideDown : .portrait
	}

	// MARK: Status bar

	override var prefersStatusBarHidden: Bool {
		return true
	}


	// MARK: UICollectionViewDataSource

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return dataSource.count
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		if dataSource[indexPath.row] == "menu_item_mariko_doujou" {
			return CGSize(width: 234, height: 78)
		}
		return CGSize(width: 78, height: 78)
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CharacterCell", for: indexPath) as! CharacterCell

		cell.iconImageView.image = UIImage(named: dataSource[indexPath.row])

		return cell
	}

	// MARK: UICollectionViewDelegate

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let name = dataSource[indexPath.row]
		if name == "menu_item_nop" {
			return
		}
		if name == "menu_item_koko" {
			washimoiruzoButton.isHidden = false
		}

		if name.hasSuffix("doujou") {
			doujouMode = name
			performSegue(withIdentifier: "NaginataSegue", sender: self)
		} else {
			gameScene.addCharacter(name: name)
		}
	}


	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		if let identifier = segue.identifier {
			if identifier == "NaginataSegue" {
				if let naginataDojo = segue.destination as? NaginataDojoViewController {
					naginataDojo.doujouMode = self.doujouMode
				}
			}
		}
	}
}
