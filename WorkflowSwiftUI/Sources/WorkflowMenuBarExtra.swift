#if os(macOS)

import SwiftUI
import Workflow

@available(macOS 13.0, *)
public struct WorkflowMenuBarExtra<Label: View, WorkflowType: Workflow>: Scene where WorkflowType.Rendering: ObservableScreen {
    private let store: Store<WorkflowType.Rendering.Model>
    private let workflowHost: WorkflowHost<WorkflowType>
    private let label: () -> Label

    public init(
        workflow: WorkflowType,
        @ViewBuilder label: @escaping () -> Label
    ) {
        workflowHost = WorkflowHost(workflow: workflow)
        let (store, setModel) = Store.make(model: workflowHost.rendering.value.model)

        self.store = store
        self.label = label

        workflowHost
            .rendering
            .signal
            .map(\.model)
            .observeValues(setModel)
    }

    public var body: some Scene {
        MenuBarExtra(content: {
            WorkflowType.Rendering.makeView(store: store)
        }, label: label)
    }
}

#endif
