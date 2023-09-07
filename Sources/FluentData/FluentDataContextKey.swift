import Foundation

/// Supported storage mediums for a context
///
/// ``memory`` won't persist data across two launches of your app. This can be quite useful during the development process.
///
/// ``file(_:)`` on the other hand, will persist data on disk using the SQLite format.
///
/// ``bundle(_:name:)`` provide a read-only database using the SQLite format from a bundle file.
/// The file will be located in the "Application Support" folder of the currently running application.
public enum FluentDataPersistence {
    case memory
    case file(_ name: String)
    case bundle(_ bundle: Bundle, name: String)
}

public enum MigrationFailurePolicy {
    case startFresh
    case abort
    case backupAndStartFresh(backupHandler: (URL) -> Void)
}

/// An unique identifier for a database context
public protocol FluentDataContextKey {
    static var logQueries: Bool { get }

    static var migrationFailurePolicy: MigrationFailurePolicy { get }
    /// The list of migrations to apply
    ///
    /// Migrations allows your data model to evolve with your app. Migrations are automatically applied in order when the database context is created.
    ///
    /// Fluent keeps track of migrations that have already been applied.
    ///
    /// For more information about the migration system of Fluent, see [Fluent's migration documentation](https://docs.vapor.codes/fluent/migration/)
    static var migrations: [Migration] { get }
    
    /// Specify how the data must be persisted for this context
    static var persistence: FluentDataPersistence { get }
}

public extension FluentDataContextKey {
    static var logQueries: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var migrationFailurePolicy: MigrationFailurePolicy {
        return .abort
    }

    static var migrations: [Migration] {
        return []
    }
}
