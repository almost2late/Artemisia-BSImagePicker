// The MIT License (MIT)
//
// Copyright (c) 2015 Joakim Gyllström
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit
import Photos

final class PreviewViewController : UIViewController {
    var imageView: UIImageView?
    private var fullscreen = false
    fileprivate var sendClojure: ((PHAsset)->())?
    
    var asset: PHAsset?
    var sendButton: UIButton?
    
    convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, sendClojure aSendClojure: @escaping (PHAsset)->()) {
        self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        sendClojure = aSendClojure
        
        addSendButton()
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
        titleLabel.text = "Camera Roll"
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        navigationItem.titleView = titleLabel
    }
    
    func setCustomBackButton() {
        let image = UIImage(named: "nav_back_button", in: BSImagePickerViewController.bundle, compatibleWith: nil)?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image, style:.plain, target:self, action:#selector(self.goBack))
        
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setCustomBackButton()
    }
    
    func addSendButton() {
        let buttonHeight: CGFloat = 60
        let button = UIButton(frame: CGRect(x: 0,
                                            y: view.bounds.size.height - buttonHeight,
                                            width: view.bounds.size.width,
                                            height: buttonHeight))
        button.backgroundColor = UIColor.white
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(self.sendButtonPressed), for: .touchUpInside)
        button.setTitleColor(UIColor.init(red: 0x3E/255.0, green: 0x75/255.0, blue: 0xFF/255.0, alpha: 1), for:.normal)
        view.addSubview(button)
        
        let upperBorder = CALayer()
        upperBorder.backgroundColor = UIColor(red: 0xE4/255.0, green: 0xE5/255.0, blue: 0xE6/255.0, alpha: 1).cgColor
        upperBorder.frame = CGRect(x: 0, y: 0, width: button.frame.size.width, height: 1)
        button.layer.addSublayer(upperBorder)
        
        sendButton = button
    }
    
    @objc func sendButtonPressed() {
        if let closure = sendClojure, let anAsset = asset {
            closure(anAsset)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.backgroundColor = UIColor.white
        
        imageView = UIImageView(frame: view.bounds)
        imageView?.contentMode = .scaleAspectFit
        imageView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView?.backgroundColor = UIColor.clear
        view.backgroundColor = UIColor.init(red: 0xF7/255.0, green: 0xF7/255.0, blue: 0xF7/255.0, alpha: 1)
        view.addSubview(imageView!)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.addTarget(self, action: #selector(PreviewViewController.toggleFullscreen))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        super.loadView()
    }
    
    @objc func toggleFullscreen() {
        fullscreen = !fullscreen
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.toggleNavigationBar()
            self.toggleStatusBar()
            self.toggleBackgroundColor()
        })
    }
    
    @objc func toggleNavigationBar() {
        navigationController?.setNavigationBarHidden(fullscreen, animated: true)
    }
    
    @objc func toggleStatusBar() {
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func toggleBackgroundColor() {
        let aColor: UIColor
        
        if self.fullscreen {
            aColor = UIColor.black
            sendButton?.alpha = 0
        } else {
            aColor = UIColor.white
            sendButton?.alpha = 1
        }
        
        self.view.backgroundColor = aColor
    }
    
    override var prefersStatusBarHidden : Bool {
        return fullscreen
    }
}
