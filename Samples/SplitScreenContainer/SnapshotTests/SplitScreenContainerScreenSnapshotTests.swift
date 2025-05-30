/*
 * Copyright 2020 Square Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import iOSSnapshotTestCase
import Workflow
import WorkflowUI
import XCTest
@testable import SplitScreenContainer

class SplitScreenContainerScreenSnapshotTests: FBSnapshotTestCase {
    override func setUp() {
        super.setUp()
        recordMode = false
        folderName = "SplitScreenContainerScreenSnapshotTests"
        fileNameOptions = [.device]
    }

    func test_splitRatio() {
        let ratios: [String: CGFloat] = [
            "third": .third,
            "quarter": .quarter,
            "half": .half,
            "custom": 0.3125,
        ]

        for (name, ratio) in ratios {
            let splitScreenContainerScreen = SplitScreenContainerScreen(
                leadingScreen: FooScreen(title: "Leading screen", backgroundColor: .green, viewTapped: {}),
                trailingScreen: FooScreen(title: "Trailing screen", backgroundColor: .red, viewTapped: {}),
                ratio: ratio
            )

            let viewController = SplitScreenContainerViewController(
                screen: splitScreenContainerScreen,
                environment: .empty
            )
            viewController.view.layoutIfNeeded()

            FBSnapshotVerifyView(viewController.view, identifier: name, suffixes: ["_64"])
        }
    }
}

private struct FooScreen: Screen {
    let title: String
    let backgroundColor: UIColor
    let viewTapped: () -> Void

    func viewControllerDescription(environment: ViewEnvironment) -> ViewControllerDescription {
        FooScreenViewController.description(for: self, environment: environment)
    }
}

private final class FooScreenViewController: ScreenViewController<FooScreen> {
    private lazy var titleLabel: UILabel = .init()
    private lazy var tapGestureRecognizer: UITapGestureRecognizer = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        tapGestureRecognizer.addTarget(self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    override func screenDidChange(from previousScreen: FooScreen, previousEnvironment: ViewEnvironment) {
        super.screenDidChange(from: previousScreen, previousEnvironment: previousEnvironment)

        view.backgroundColor = screen.backgroundColor
        titleLabel.text = screen.title
    }

    @objc
    private func viewTapped() {
        screen.viewTapped()
    }
}
