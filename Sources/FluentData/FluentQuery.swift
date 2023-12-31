import Combine
import Dispatch
import FluentKit

/// A query object, auto-updating with Combine
public class FluentQuery<Model: FluentKit.Model> {
    private let context: FluentDataContext
    internal let queryBuilder: (QueryBuilder<Model>) -> QueryBuilder<Model>
    internal let queryId: UUID

    // swiftlint:disable private_subject
    internal let subject = CurrentValueSubject<[Model], Error>([])
    // swiftlint:enable private_subject

    /// Any subscriber to this publisher will receive new updates everytime FluentData determines the result has to be updated.
    public var publisher: AnyPublisher<[Model], Error> {
        subject
            .receive(on: DispatchQueue.main)
            .map { [self] model in
                // Explicitly retaining self to make sure the query doesn't deregister as long as its published is retained
                _ = self
                return model
            }
            .eraseToAnyPublisher()
    }

    /// Create a query object to fetch entries from the specified database context
    /// - Parameters:
    ///   - context: the context object
    ///   - queryBuilder: optional, can be specified to customize the query, such as filters or the sort order
    public init(
        context: FluentDataContext,
        queryBuilder: @escaping (QueryBuilder<Model>) -> QueryBuilder<Model> = { $0 }
    ) {
        self.context = context
        self.queryBuilder = queryBuilder
        self.queryId = UUID()
        self.context.register(self)
    }

    /// Create a query object to fetch entries from the specified database context key
    /// - Parameters:
    ///   - contextKey: the key which uniquely identify this context
    ///   - queryBuilder: optional, can be specified to customize the query, such as filters or the sort order
    public convenience init<TContextKey: FluentDataContextKey>(
        contextKey: TContextKey.Type,
        queryBuilder: @escaping (QueryBuilder<Model>) -> QueryBuilder<Model> = { $0 }
    ) {
        self.init(context: FluentDataContexts[contextKey], queryBuilder: queryBuilder)
    }

    /// Create a query object to fetch entries from the default database context
    /// - Parameters:
    ///   - queryBuilder: optional, can be specified to customize the query, such as filters or the sort order
    public convenience init(
        queryBuilder: @escaping (QueryBuilder<Model>) -> QueryBuilder<Model> = { $0 }
    ) {
        guard let context = FluentDataContexts.default else {
            fatalError("FluentData has no default context")
        }
        self.init(context: context, queryBuilder: queryBuilder)
    }

    deinit {
        self.context.deregister(self)
    }
}
