//
//  ViewController.swift
//  Milestone25-27
//
//  Created by Anton Makeev on 23.04.2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var topText: String?
    var bottomText: String?
    var imageToTextRatio: CGFloat = 4
    
    @IBOutlet var imageView: UIImageView!
    var originalImage: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "photo"), style: .plain, target: self, action: #selector(chooseImage))
        navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editText))
    }

    @objc func chooseImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var image = info[.editedImage] as? UIImage else { return }
        originalImage = image
        if topText != nil || bottomText != nil {
            image = applyTextTo(image: image)
        }
        imageView.image = image
        dismiss(animated: true)
    }
    
    func applyTextTo(image: UIImage) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let renderedImage = renderer.image { ctx in
            image.draw(at: CGPoint(x: 0, y: 0))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = 1
            let attrs: [NSAttributedString.Key : Any] = [
                .foregroundColor : UIColor.white,
                .paragraphStyle : paragraphStyle
            ]
            let strokeAttrs: [NSAttributedString.Key : Any] = [
                .strokeColor : UIColor.black,
                .strokeWidth : 2,
                .paragraphStyle : paragraphStyle,
            ]
            
            if let topText = topText {
                let fontSize = fontSizeToFit(text: topText, into: image.size)
                let font = UIFont.systemFont(ofSize: fontSize)
                let positionRect =  CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height/imageToTextRatio)
                
                let topStrokeAttributedString = NSMutableAttributedString(string: topText, attributes: strokeAttrs)
                topStrokeAttributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: topStrokeAttributedString.length))
                topStrokeAttributedString.draw(with: positionRect, options: .usesLineFragmentOrigin, context: nil)
                
                let topAttributedString = NSMutableAttributedString(string: topText, attributes: attrs)
                topAttributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: topAttributedString.length))
                topAttributedString.draw(with: positionRect, options: .usesLineFragmentOrigin, context: nil)
            }
            
            if let bottomText = bottomText {
                let fontSize = fontSizeToFit(text: bottomText, into: image.size)
                let font = UIFont.systemFont(ofSize: fontSize)
                
                let positionRect =  CGRect(x: 0, y: image.size.height/imageToTextRatio*3, width: image.size.width, height: image.size.height/imageToTextRatio)
                let bottoStrokeTextAttributedString = NSMutableAttributedString(string: bottomText, attributes: strokeAttrs)
                bottoStrokeTextAttributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: bottoStrokeTextAttributedString.length))
                bottoStrokeTextAttributedString.draw(with: positionRect, options: .usesLineFragmentOrigin, context: nil)
                
                let bottomTextAttributedString = NSMutableAttributedString(string: bottomText, attributes: attrs)
                bottomTextAttributedString.addAttribute(.font, value: font, range: NSRange(location: 0, length: bottomTextAttributedString.length))
                bottomTextAttributedString.draw(with: positionRect, options: .usesLineFragmentOrigin, context: nil)
            }
        }
        return renderedImage
    }
    
    func fontSizeToFit(text: String, into size: CGSize ) -> CGFloat {
        var i = imageToTextRatio + 1
        var textSize = (text as NSString).size(withAttributes: [ .font : UIFont.systemFont(ofSize: size.height / i)])
        while textSize.width * textSize.height > size.width * size.height / imageToTextRatio {
            i += imageToTextRatio + 2
            textSize = (text as NSString).size(withAttributes: [ .font : UIFont.systemFont(ofSize: size.height / i)])
        }
        return size.height / i
    }
    
    @objc func editText() {
        let ac = UIAlertController(title: "Enter text", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Text on the top"
            textField.clearButtonMode = .whileEditing
        }
        ac.addTextField { textField in
            textField.placeholder = "Text on the bottom"
            textField.clearButtonMode = .whileEditing
        }
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            self?.topText = ac.textFields?[0].text
            self?.bottomText = ac.textFields?[1].text
            if (self?.topText != nil || self?.bottomText != nil), let image = self?.originalImage {
                self?.imageView.image = self?.applyTextTo(image: image)
            }
        }
        )
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func shareTapped() {
        guard let image = imageView.image else { return }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(vc, animated: true)
    }
    
}

