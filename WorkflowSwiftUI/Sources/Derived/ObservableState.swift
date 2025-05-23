// Derived from
// https://github.com/pointfreeco/swift-composable-architecture/blob/1.12.1/Sources/ComposableArchitecture/Observation/ObservableState.swift

import Foundation
import IdentifiedCollections

/// A type that emits notifications to observers when underlying data changes.
///
/// Conforming to this protocol signals to other APIs that the value type supports observation.
/// However, applying the ``ObservableState`` protocol by itself to a type doesn’t add observation
/// functionality to the type. Instead, always use the ``ObservableState()`` macro when adding
/// observation support to a type.
public protocol ObservableState: Observable {
    var _$id: ObservableStateID { get }
    mutating func _$willModify()
}

/// A unique identifier for a observed value.
public struct ObservableStateID: Equatable, Hashable, Sendable {
    @usableFromInline
    var location: UUID {
        get { storage.id.location }
        set {
            if !isKnownUniquelyReferenced(&storage) {
                storage = Storage(id: storage.id)
            }
            storage.id.location = newValue
        }
    }

    private var storage: Storage

    private init(storage: Storage) {
        self.storage = storage
    }

    public init() {
        self.init(storage: Storage(id: .location(UUID())))
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.storage === rhs.storage || lhs.storage.id == rhs.storage.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(storage.id)
    }

    @inlinable
    public static func _$id(for value: some Any) -> Self {
        (value as? any ObservableState)?._$id ?? Self()
    }

    @inlinable
    public static func _$id(for value: some ObservableState) -> Self {
        value._$id
    }

    public func _$tag(_ tag: Int) -> Self {
        Self(storage: Storage(id: .tag(tag, storage.id)))
    }

    @inlinable
    public mutating func _$willModify() {
        location = UUID()
    }

    private final class Storage: @unchecked Sendable {
        fileprivate var id: ID

        init(id: ID = .location(UUID())) {
            self.id = id
        }

        enum ID: Equatable, Hashable, Sendable {
            case location(UUID)
            indirect case tag(Int, ID)

            var location: UUID {
                get {
                    switch self {
                    case .location(let location):
                        location
                    case .tag(_, let id):
                        id.location
                    }
                }
                set {
                    switch self {
                    case .location:
                        self = .location(newValue)
                    case .tag(let tag, var id):
                        id.location = newValue
                        self = .tag(tag, id)
                    }
                }
            }
        }
    }
}

@inlinable
public func _$isIdentityEqual<T: ObservableState>(
    _ lhs: T, _ rhs: T
) -> Bool {
    lhs._$id == rhs._$id
}

@inlinable
public func _$isIdentityEqual<ID: Hashable, T: ObservableState>(
    _ lhs: IdentifiedArray<ID, T>,
    _ rhs: IdentifiedArray<ID, T>
) -> Bool {
    areOrderedSetsDuplicates(lhs.ids, rhs.ids)
}

@inlinable
public func _$isIdentityEqual<C: Collection>(
    _ lhs: C,
    _ rhs: C
) -> Bool
    where C.Element: ObservableState
{
    lhs.count == rhs.count && zip(lhs, rhs).allSatisfy { $0._$id == $1._$id }
}

// NB: This is a fast path so that String is not checked as a collection.
@inlinable
public func _$isIdentityEqual(_ lhs: String, _ rhs: String) -> Bool {
    false
}

@inlinable
public func _$isIdentityEqual<T>(_ lhs: T, _ rhs: T) -> Bool {
    guard !_isPOD(T.self) else { return false }

    func openCollection<C: Collection>(_ lhs: C, _ rhs: Any) -> Bool {
        guard C.Element.self is ObservableState.Type else {
            return false
        }

        func openIdentifiable<Element: Identifiable>(_: Element.Type) -> Bool? {
            guard
                let lhs = lhs as? IdentifiedArrayOf<Element>,
                let rhs = rhs as? IdentifiedArrayOf<Element>
            else {
                return nil
            }
            return areOrderedSetsDuplicates(lhs.ids, rhs.ids)
        }

        if let identifiable = C.Element.self as? any Identifiable.Type,
           let result = openIdentifiable(identifiable)
        {
            return result
        } else if let rhs = rhs as? C {
            return lhs.count == rhs.count && zip(lhs, rhs).allSatisfy(_$isIdentityEqual)
        } else {
            return false
        }
    }

    if let lhs = lhs as? any ObservableState, let rhs = rhs as? any ObservableState {
        return lhs._$id == rhs._$id
    } else if let lhs = lhs as? any Collection {
        return openCollection(lhs, rhs)
    } else {
        return false
    }
}

@inlinable
public func _$willModify(_: inout some Any) {}
@inlinable
public func _$willModify(_ value: inout some ObservableState) {
    value._$willModify()
}
