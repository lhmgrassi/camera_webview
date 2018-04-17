//
//  ViewController.swift
//  webviewCamera
//
//  Created by Luis Grassi on 17/04/18.
//  Copyright © 2018 grassi. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

	var webView: WKWebView!

	override func viewDidLoad() {
		super.viewDidLoad()

		let config = WKWebViewConfiguration()
		let userContentController = WKUserContentController()
		config.userContentController = userContentController

		self.webView = WKWebView(frame: self.view.bounds, configuration: config)
		userContentController.add(self, name: "openCamera")

		self.view = self.webView
		self.webView.loadHTMLString(self.HTMLString(), baseURL: nil)
	}

	func HTMLString() -> String {
		return """
		<html>

			<body>
				<button onclick="openCamera();" type="button">take a picture</button>
				<img height="200" width="200" id="myImage">
			</body>

			<script>
				function openCamera() {
					window.webkit.messageHandlers.openCamera.postMessage("");
				}

				function cameraCallback(imageData) {
					var image = document.getElementById('myImage');
					image.src = "data:image/jpeg;base64," + imageData;
				}
			</script>

		</html>
		"""
	}
}

extension ViewController: WKScriptMessageHandler {

	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		guard
			message.name == "openCamera",
			UIImagePickerController.isSourceTypeAvailable(.camera) else {
				return
		}

		let imagePickerController = UIImagePickerController()
		imagePickerController.delegate = self
		imagePickerController.sourceType = .camera;
		imagePickerController.allowsEditing = false
		self.present(imagePickerController, animated: true, completion: nil)
	}
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		let image = info[UIImagePickerControllerOriginalImage] as! UIImage
		let imageData = UIImagePNGRepresentation(image)!

		let javaScript = "cameraCallback('" + imageData.base64EncodedString() + "')"
		self.webView.evaluateJavaScript(javaScript) { (result, error) in
			if error != nil {
				print(result)
			} else {
				print("error: \(error?.localizedDescription)")
			}
		}

		picker.dismiss(animated: true, completion: nil)
	}
}

