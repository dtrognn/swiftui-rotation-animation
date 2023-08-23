//
//  RotationViewModel.swift
//  rotation-animation
//
//  Created by dtrognn on 23/08/2023.
//

import Combine
import Foundation

enum SpeedSelected {
    case off
    case one
    case two
    case three
    case four
}

class RotationViewModel: ObservableObject {
    @Published var currentSpeed: Double = 0.0
    @Published var speedSelected: SpeedSelected = .off

    var onChangedSpeed = PassthroughSubject<Double, Never>()
    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        subcribe()
    }

    private func subcribe() {
        onChangedSpeed.sink { speed in
            self.currentSpeed = speed
        }.store(in: &cancellableSet)
    }
}
