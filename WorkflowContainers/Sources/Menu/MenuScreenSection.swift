// Copyright © Fleuronic LLC. All rights reserved.

#if canImport(AppKit)

import Workflow
import WorkflowUI
import WorkflowMenuUI

public extension Menu.Screen {
	struct Section {
		let key: AnyHashable
		let screen: ScreenType
	}
}

// MARK: -
public extension Menu.Screen.Section {
	init<Key: Hashable>(
		key: Key? = AnyHashable?.none,
		screen: ScreenType
	) {
		self.screen = screen

		if let key {
			self.key = .init(key)
		} else {
			self.key = .init(ObjectIdentifier(ScreenType.self))
		}
	}
}

// MARK: -
public extension AnyWorkflowConvertible where Rendering: WorkflowMenuUI.Screen {
	func mapRendering<Key: Hashable>(section: Key) -> AnyWorkflow<Menu.Screen<AnyScreen>.Section, Output> {
		asAnyWorkflow().mapRendering { screen in
			.init(
				key: section,
				screen: screen.asAnyScreen()
			)
		}
	}
}

#endif
