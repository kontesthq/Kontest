// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CodeChefUserInfoQuery: GraphQLQuery {
  public static let operationName: String = "CodeChefUserInfoQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CodeChefUserInfoQuery($username: String!) { codeChefQuery { __typename getCodeChefUser(username: $username) { __typename success profile name currentRating highestRating countryFlag countryName globalRank countryRank stars } } }"#
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
        .field("getCodeChefUser", GetCodeChefUser?.self, arguments: ["username": .variable("username")]),
      ] }

      public var getCodeChefUser: GetCodeChefUser? { __data["getCodeChefUser"] }

      /// CodeChefQuery.GetCodeChefUser
      ///
      /// Parent Type: `CodeChefUser`
      public struct GetCodeChefUser: KontestGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeChefUser }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("success", Bool.self),
          .field("profile", String.self),
          .field("name", String.self),
          .field("currentRating", Int.self),
          .field("highestRating", Int.self),
          .field("countryFlag", String.self),
          .field("countryName", String.self),
          .field("globalRank", Int.self),
          .field("countryRank", Int.self),
          .field("stars", String.self),
        ] }

        public var success: Bool { __data["success"] }
        public var profile: String { __data["profile"] }
        public var name: String { __data["name"] }
        public var currentRating: Int { __data["currentRating"] }
        public var highestRating: Int { __data["highestRating"] }
        public var countryFlag: String { __data["countryFlag"] }
        public var countryName: String { __data["countryName"] }
        public var globalRank: Int { __data["globalRank"] }
        public var countryRank: Int { __data["countryRank"] }
        public var stars: String { __data["stars"] }
      }
    }
  }
}
