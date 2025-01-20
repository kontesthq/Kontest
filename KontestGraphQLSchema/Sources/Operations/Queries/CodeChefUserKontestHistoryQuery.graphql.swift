// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CodeChefUserKontestHistoryQuery: GraphQLQuery {
  public static let operationName: String = "CodeChefUserKontestHistoryQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CodeChefUserKontestHistoryQuery($username: String!) { codeChefQuery { __typename getUserKontestHistory(username: $username) { __typename code year month day reason penalisedIn rating rank name endDate color } } }"#
    ))

  public var username: String

  public init(username: String) {
    self.username = username
  }

  public var __variables: Variables? { ["username": username] }

  public struct Data: KontestGraphQLSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("codeChefQuery", CodeChefQuery?.self),
    ] }

    public var codeChefQuery: CodeChefQuery? { __data["codeChefQuery"] }

    /// CodeChefQuery
    ///
    /// Parent Type: `CodeChefQuery`
    public struct CodeChefQuery: KontestGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeChefQuery }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("getUserKontestHistory", [GetUserKontestHistory?]?.self, arguments: ["username": .variable("username")]),
      ] }

      public var getUserKontestHistory: [GetUserKontestHistory?]? { __data["getUserKontestHistory"] }

      /// CodeChefQuery.GetUserKontestHistory
      ///
      /// Parent Type: `CodeChefContest`
      public struct GetUserKontestHistory: KontestGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeChefContest }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("code", String.self),
          .field("year", Int.self),
          .field("month", Int.self),
          .field("day", Int.self),
          .field("reason", String?.self),
          .field("penalisedIn", Bool.self),
          .field("rating", Int.self),
          .field("rank", Int.self),
          .field("name", String.self),
          .field("endDate", String.self),
          .field("color", String.self),
        ] }

        public var code: String { __data["code"] }
        public var year: Int { __data["year"] }
        public var month: Int { __data["month"] }
        public var day: Int { __data["day"] }
        public var reason: String? { __data["reason"] }
        public var penalisedIn: Bool { __data["penalisedIn"] }
        public var rating: Int { __data["rating"] }
        public var rank: Int { __data["rank"] }
        public var name: String { __data["name"] }
        public var endDate: String { __data["endDate"] }
        public var color: String { __data["color"] }
      }
    }
  }
}
