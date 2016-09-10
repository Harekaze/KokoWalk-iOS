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

private let reuseIdentifier = "Cell"

class KokoMainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

	// MARK: - Private constant values
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
		"menu_item_koko_doujou_hard",
		"menu_item_oyabun_doujou",
		"menu_item_nop",
		"menu_item_nop",
		"menu_item_nop",
	]
	
	// MARK: - Private instance fields
	private var gameScene: GameScene!

	// MARK: - Interface Builder outlets
	
	@IBOutlet weak var sceneView: SKView!
	@IBOutlet weak var characterModeCollectionView: UICollectionView!
	
	// MARK: - View initialization
	
	override func viewDidLoad() {
		super.viewDidLoad()

		self.characterModeCollectionView.delegate = self
		
		if let scene = GKScene(fileNamed: "GameScene") {
			
			// Get the SKScene from the loaded GKScene
			if let sceneNode = scene.rootNode as! GameScene? {
				self.gameScene = sceneNode
				
				// Copy gameplay related content over to the scene
				sceneNode.graphs = scene.graphs
				
				// Set the scale mode to scale to fit the window
				sceneNode.scaleMode = .aspectFill
				
				// Present the scene
				sceneView.presentScene(sceneNode)
				
				sceneView.ignoresSiblingOrder = true
				
				sceneView.showsFPS = true
				sceneView.showsNodeCount = true
			}
		}

	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using [segue destinationViewController].
		// Pass the selected object to the new view controller.
	}
	*/

	
	// MARK: - Device rotation
	
	override var shouldAutorotate: Bool {
		return true
	}
	
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}
	
	// MARK: - Status bar
	
	override var prefersStatusBarHidden: Bool {
		return true
	}

	
	// MARK: UICollectionViewDataSource

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}


	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of items
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
		gameScene.addCharacter(name: "")
	}

	/*
	// Uncomment this method to specify if the specified item should be highlighted during tracking
	override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	*/

	/*
	// Uncomment this method to specify if the specified item should be selected
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	*/

	/*
	// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
	override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
		return false
	}

	override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		return false
	}

	override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
	
	}
	*/

}
