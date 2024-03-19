//
//  ViewController.swift
//  Lesson16
//
//  Created by Виктор Реут on 18.03.24.
//

import UIKit

class ViewController: UIViewController {
    private let box = UIView()
    
    private var widthConstraint: NSLayoutConstraint!
    private var heightConstraint: NSLayoutConstraint!
    private var centerYConstraint: NSLayoutConstraint!
    private var centerXConstraint: NSLayoutConstraint!
    
    private let initialBoxWidth: CGFloat = 150
    private let initialBoxHeight: CGFloat = 100
    
    private let panGestureRecognizer = UIPanGestureRecognizer()
    private var panGestureAnchorPoint: CGPoint? = nil
    
    private var pinchGestureRecognizer = UIPinchGestureRecognizer()
    private var pinchGestureAnchorScale: CGFloat? = nil
    private var scale: CGFloat = 1 {
        didSet {
            updateBoxTransform()
        }
    }
    
    private var rotateGestureRecognizer = UIRotationGestureRecognizer()
    private var rotateGestureAnchorRotation: CGFloat?
    private var rotation: CGFloat = 0 {
        didSet {
            updateBoxTransform()
        }
    }
    
    private let singleTapGestureRecognizer = UITapGestureRecognizer()
    private var originalColor = UIColor()
    private var isColorChanged = false
    
    private let doubleTapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupBox()
        setupGestureRecognizers()
        
    }
    
    func setupBox() {
        view.addSubview(box)
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = .red
        
        originalColor = box.backgroundColor ?? UIColor.white
        
        widthConstraint = box.widthAnchor.constraint(equalToConstant: initialBoxWidth)
        heightConstraint = box.heightAnchor.constraint(equalToConstant: initialBoxHeight)
        centerYConstraint = box.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        centerXConstraint = box.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        
        NSLayoutConstraint.activate([
            widthConstraint,
            heightConstraint,
            centerXConstraint,
            centerYConstraint
        ])
    }
    
    func setupGestureRecognizers() {
        panGestureRecognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.maximumNumberOfTouches = 1
        
        pinchGestureRecognizer.addTarget(self, action: #selector(handlePinchGesture(_:)))
        
        rotateGestureRecognizer.addTarget(self, action: #selector(handleRotateGesture(_:)))
        
        singleTapGestureRecognizer.addTarget(self, action: #selector(handleSingleTapGesture))
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        doubleTapGestureRecognizer.addTarget(self, action: #selector(handleDoubleTapGesture))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        [panGestureRecognizer, pinchGestureRecognizer, rotateGestureRecognizer, singleTapGestureRecognizer, doubleTapGestureRecognizer].forEach { $0.delegate = self }
        
        box.addGestureRecognizer(panGestureRecognizer)
        box.addGestureRecognizer(pinchGestureRecognizer)
        box.addGestureRecognizer(rotateGestureRecognizer)
        box.addGestureRecognizer(singleTapGestureRecognizer)
        box.addGestureRecognizer(doubleTapGestureRecognizer)
        
    }


}

private extension ViewController {
    
    @objc
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            
        case .possible:
            break
        case .began:
            panGestureAnchorPoint = recognizer.location(in: view)
        case .changed:
            guard let panGestureAnchorPoint = panGestureAnchorPoint else { return }
            let point = recognizer.location(in: view)
            centerXConstraint.constant += point.x - panGestureAnchorPoint.x
            centerYConstraint.constant += point.y - panGestureAnchorPoint.y
            self.panGestureAnchorPoint = point
        case .ended:
            panGestureAnchorPoint = nil
        case .cancelled:
            panGestureAnchorPoint = nil
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
    @objc
    func handlePinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
            
        case .possible:
            break
        case .began:
            pinchGestureAnchorScale = recognizer.scale
        case .changed:
            guard let pinchGestureAnchorScale = pinchGestureAnchorScale else { return }
            let scale = recognizer.scale
            self.scale += scale - pinchGestureAnchorScale
            self.pinchGestureAnchorScale = scale
        case .ended:
            pinchGestureAnchorScale = nil
        case .cancelled:
            pinchGestureAnchorScale = nil
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
    @objc
    func handleRotateGesture(_ recognizer: UIRotationGestureRecognizer) {
        switch recognizer.state {
            
        case .possible:
            break
        case .began:
            rotateGestureAnchorRotation = recognizer.rotation
        case .changed:
            guard let rotateGestireAnchorRotation = rotateGestureAnchorRotation else { return }
            let localRotation = recognizer.rotation
            self.rotation += localRotation - rotateGestireAnchorRotation
            self.rotateGestureAnchorRotation = localRotation
        case .ended:
            rotateGestureAnchorRotation = nil
        case .cancelled:
            rotateGestureAnchorRotation = nil
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
    @objc
    func handleSingleTapGesture() {
        if isColorChanged {
            UIView.animate(withDuration: 0.5) {
                self.box.backgroundColor = self.originalColor
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.box.backgroundColor = UIColor.black
            }
        }
        
        isColorChanged.toggle()
    }
    
    @objc
    func handleDoubleTapGesture() {
        widthConstraint.constant = initialBoxWidth
        heightConstraint.constant = initialBoxHeight
        centerXConstraint.constant = 0.0
        centerYConstraint.constant = 0.0

        UIView.animate(
            withDuration: 0.3,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: {
                self.scale = 1.0
                self.rotation = 0.0
                self.view.layoutIfNeeded()
            },
            completion: nil
        )
    }
}

private extension ViewController {
    func updateBoxTransform() {
        box.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            .rotated(by: rotation)
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let recognizers = [
            panGestureRecognizer,
            pinchGestureRecognizer,
            rotateGestureRecognizer,
            singleTapGestureRecognizer,
            doubleTapGestureRecognizer
        ]
        
        return recognizers.contains(gestureRecognizer) && recognizers.contains(otherGestureRecognizer)
    }

}
