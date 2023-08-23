//
//  ImageRotationAnimationView.swift
//  rotation-animation
//
//  Created by dtrognn on 23/08/2023.
//

import Combine
import Foundation
import SwiftUI
import UIKit

public struct ImageRotationAnimationView: UIViewRepresentable {
    public typealias UIViewType = UIImageView

    @ObservedObject public var store: ImageRotationAnimationViewModel

    public init(store: ImageRotationAnimationViewModel) {
        self.store = store
    }

    public func makeUIView(context: Context) -> UIImageView {
        return store.imageView
    }

    public func updateUIView(_ uiView: UIImageView, context: Context) {}
}

public class ImageRotationAnimationViewModel: ObservableObject {
    public enum RotationDirection {
        case leftToRight
        case rightToLeft
    }

    private let rotationAnimationKey = "rotationAnimation"
    private var rotationAnimation: CABasicAnimation?
    private var timerAnimation: Timer.TimerPublisher?

    public var speedRatio: Double = 1.0
    public var speedStopMin: Double = 0.5
    public var speedReduce: Double = 0.1
    public var speedMin: Double = 1.0
    public var timerAnimationRepeat: TimeInterval = 0.3

    var imageView = UIImageView()
    private let rotationDirection: RotationDirection

    private var cancellableSet: Set<AnyCancellable> = []

    public init(image: UIImage, rotationDirection: RotationDirection = .rightToLeft) {
        imageView.image = image
        self.rotationDirection = rotationDirection
        initRotationAnimation()
    }

    public func updateConfigure(speedRatio: Double = 1.0, speedStopMin: Double = 0.5, speedReduce: Double = 0.1, speedMin: Double = 1.0, timerAnimationRepeat: TimeInterval = 0.3) {
        self.speedRatio = speedRatio
        self.speedStopMin = speedStopMin
        self.speedReduce = speedReduce
        self.speedMin = speedMin
        self.timerAnimationRepeat = timerAnimationRepeat
    }

    public func initRotationAnimation() {
        imageView.layer.removeAnimation(forKey: rotationAnimationKey)
        rotationAnimation = nil

        if rotationAnimation == nil {
            rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            if rotationDirection == .rightToLeft {
                rotationAnimation?.toValue = NSNumber(value: -.pi * 2.0)
            } else {
                rotationAnimation?.toValue = NSNumber(value: .pi * 2.0)
            }
            rotationAnimation?.duration = 1
            rotationAnimation?.isCumulative = true
            rotationAnimation?.repeatCount = .infinity
            imageView.layer.add(rotationAnimation!, forKey: rotationAnimationKey)
        } else {
            imageView.layer.add(rotationAnimation!, forKey: rotationAnimationKey)
        }
        updateSpeedAnimation(0)
    }

    private func updateSpeedAnimation(_ newSpeed: Double) {
        if newSpeed == 0 {
            imageView.layer.timeOffset = 0
            imageView.layer.beginTime = 0
            imageView.layer.speed = 0
            return
        }

        imageView.layer.timeOffset = imageView.layer.convertTime(CACurrentMediaTime(), from: nil)
        imageView.layer.beginTime = CACurrentMediaTime()
        imageView.layer.speed = Float(newSpeed)
    }

    private func stopTimerAnimation() {
        timerAnimation?.autoconnect().upstream.connect().cancel()
    }

    private func speedWithRatio(_ speed: Double) -> Double {
        return speed * speedRatio
    }

    public func startAnimation(_ newSpeed: Double) {
        let speed = speedWithRatio(newSpeed)
        stopTimerAnimation()
        if speed < speedMin {
            updateSpeedAnimation(speedMin)
        } else {
            updateSpeedAnimation(speed)
        }
    }

    public func stopAnimation(_ lastSpeed: Double) {
        stopTimerAnimation()
        var speedStop = speedWithRatio(lastSpeed)
        if speedStop == 0 {
            updateSpeedAnimation(0)
            return
        }

        timerAnimation = Timer.publish(every: TimeInterval(timerAnimationRepeat), on: .main, in: .common)
        timerAnimation?.autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if speedStop <= self.speedStopMin {
                    self.updateSpeedAnimation(0)
                    self.stopTimerAnimation()
                    return
                } else {
                    self.updateSpeedAnimation(speedStop)
                }
                speedStop -= self.speedReduce
            }.store(in: &cancellableSet)
    }

    public func removeAnimation() {
        imageView.layer.removeAnimation(forKey: rotationAnimationKey)
        rotationAnimation = nil
    }
}
