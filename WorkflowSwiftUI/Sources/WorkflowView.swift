import SwiftUI
import Workflow
import WorkflowUI

#if canImport(UIKit)

public struct WorkflowView<WorkflowType: Workflow>: UIViewControllerRepresentable where WorkflowType.Rendering: ObservableScreen {
	private let workflow: WorkflowType

	public init(workflow: WorkflowType) {
		self.workflow = workflow
	}

	public func makeUIViewController(context: Context) -> WorkflowHostingController<WorkflowType.Rendering, WorkflowType.Output> {
		.init(workflow: workflow)
	}

	public func updateUIViewController(_ uiViewController: WorkflowHostingController<WorkflowType.Rendering, WorkflowType.Output>, context: Context) {
		uiViewController.update(workflow: workflow)
	}
}

#elseif canImport(AppKit)

public struct WorkflowView<WorkflowType: Workflow>: NSViewControllerRepresentable where WorkflowType.Rendering: ObservableScreen {
	private let workflow: WorkflowType

	public init(workflow: WorkflowType) {
		self.workflow = workflow
	}

	public func makeNSViewController(context: Context) -> WorkflowHostingController<WorkflowType.Rendering, WorkflowType.Output> {
		.init(workflow: workflow)
	}

	public func updateNSViewController(_ nsViewController: WorkflowHostingController<WorkflowType.Rendering, WorkflowType.Output>, context: Context) {
		nsViewController.update(workflow: workflow)
	}
}

#endif
