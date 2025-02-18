import SwiftUI
import Workflow
import WorkflowUI
import ReactiveSwift

#if canImport(UIKit)

public struct WorkflowView<WorkflowType: Workflow>: UIViewControllerRepresentable where WorkflowType.Rendering: ObservableScreen {
	private let workflow: WorkflowType
    private let onOutput: ((WorkflowType.Output) -> Void)?

	public init(
        workflow: WorkflowType,
        onOutput: @escaping (WorkflowType.Output) -> Void
    ) {
		self.workflow = workflow
        self.onOutput = onOutput
	}

    public init(workflow: WorkflowType) where WorkflowType.Output == Never {
        self.workflow = workflow
        onOutput = nil
    }

	public func makeUIViewController(context: Context) -> WorkflowHostingController<WorkflowType.Rendering, WorkflowType.Output> {
        let controller = WorkflowHostingController(workflow: workflow)

        if let onOutput {
            context.coordinator.outputDisposable?.dispose()
            context.coordinator.outputDisposable = controller.output.observeValues(onOutput)
        }

        return controller
	}

	public func updateUIViewController(_ controller: WorkflowHostingController<WorkflowType.Rendering, WorkflowType.Output>, context: Context) {
        if let onOutput {
            context.coordinator.outputDisposable?.dispose()
            context.coordinator.outputDisposable = controller.output.observeValues(onOutput)
        }

        controller.update(workflow: workflow)
	}

    public func makeCoordinator() -> Coordinator {
        .init()
    }

    public final class Coordinator {
        var outputDisposable: Disposable?
    }
}

#elseif canImport(AppKit)

public struct WorkflowView<WorkflowType: Workflow>: NSViewControllerRepresentable where WorkflowType.Rendering: ObservableScreen {
    private let workflow: WorkflowType
    private let onOutput: ((WorkflowType.Output) -> Void)?

    public init(
        workflow: WorkflowType,
        onOutput: @escaping (WorkflowType.Output) -> Void
    ) {
        self.workflow = workflow
        self.onOutput = onOutput
    }

    public init(workflow: WorkflowType) where WorkflowType.Output == Never {
        self.workflow = workflow
        onOutput = nil
    }

    public func makeNSViewController(context: Context) -> WorkflowHostingController<WorkflowType.Rendering, WorkflowType.Output> {
        let controller = WorkflowHostingController(workflow: workflow)

        if let onOutput {
            context.coordinator.outputDisposable?.dispose()
            context.coordinator.outputDisposable = controller.output.observeValues(onOutput)
        }

        return controller
    }

    public func updateNSViewController(_ controller: WorkflowHostingController<WorkflowType.Rendering, WorkflowType.Output>, context: Context) {
        if let onOutput {
            context.coordinator.outputDisposable?.dispose()
            context.coordinator.outputDisposable = controller.output.observeValues(onOutput)
        }

        controller.update(workflow: workflow)
    }

    public func makeCoordinator() -> Coordinator {
        .init()
    }

    public final class Coordinator {
        var outputDisposable: Disposable?
    }
}

#endif
