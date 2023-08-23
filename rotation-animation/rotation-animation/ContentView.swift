//
//  ContentView.swift
//  rotation-animation
//
//  Created by dtrognn on 23/08/2023.
//

import SwiftUI

extension UIImage {
    static func image(_ name: String) -> UIImage {
        return UIImage(named: name, in: Bundle.main, compatibleWith: nil) ?? UIImage()
    }
}

struct ContentView: View {
    @StateObject private var viewModel = RotationViewModel()
    @StateObject private var imageRotationViewModel: ImageRotationAnimationViewModel

    init() {
        let imageRotation = ImageRotationAnimationViewModel(image: UIImage.image("shuriken"))
        imageRotation.updateConfigure(speedRatio: 0.7)
        _imageRotationViewModel = StateObject(wrappedValue: imageRotation)
    }

    var body: some View {
        VStack {
            Spacer()
            VStack {
                ImageRotationAnimationView(store: imageRotationViewModel)
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }

            Spacer()

            HStack {
                ChangeSpeedView(speed: "0") {
                    viewModel.speedSelected = .off
                    imageRotationViewModel.stopAnimation(viewModel.currentSpeed)
                }

                ChangeSpeedView(speed: "1", isSelected: viewModel.speedSelected == .one) {
                    viewModel.speedSelected = .one
                    changedSpeed(speed: 1.0)
                }

                ChangeSpeedView(speed: "2", isSelected: viewModel.speedSelected == .two) {
                    viewModel.speedSelected = .two
                    changedSpeed(speed: 2.0)
                }

                ChangeSpeedView(speed: "3", isSelected: viewModel.speedSelected == .three) {
                    viewModel.speedSelected = .three
                    changedSpeed(speed: 3.0)
                }

                ChangeSpeedView(speed: "4", isSelected: viewModel.speedSelected == .four) {
                    viewModel.speedSelected = .four
                    changedSpeed(speed: 4.0)
                }
            }

            Spacer()
        }
        .padding()
    }
}

struct ChangeSpeedView: View {
    var speed: String
    var isSelected: Bool?
    var onAction: () -> Void

    var body: some View {
        Button {
            onAction()
        } label: {
            Text(speed)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black)
                .padding()
                .background((isSelected ?? false) ? Color.orange : Color.gray)
                .clipShape(Circle())
        }
    }
}

private extension ContentView {
    func changedSpeed(speed: Double) {
        viewModel.onChangedSpeed.send(speed)
        imageRotationViewModel.startAnimation(viewModel.currentSpeed)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
