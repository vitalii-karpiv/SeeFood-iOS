//
//  ViewController.swift
//  SeeFood
//
//  Created by newbie on 19.03.2022.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    private let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Converting User Picked Image into CIImage Failed")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    private func detect(image: CIImage) {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("Loading CoreML Model Failed")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results else {
                fatalError("Model Failed to proceed image")
            }
            
            if let firstResult = results.first {
                if let identifier = firstResult.value(forKey: "identifier") as? String {
                    if identifier.contains("hotdog") {
                        self.navigationItem.title = "Hotdog!"
                    } else {
                        self.navigationItem.title = "Not Hotdog!"
                    }
                }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
    @IBAction func cameraTepped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

