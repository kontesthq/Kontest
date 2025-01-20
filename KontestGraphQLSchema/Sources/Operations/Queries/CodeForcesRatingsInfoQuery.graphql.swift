// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CodeForcesRatingsInfoQuery: GraphQLQuery {
  public static let operationName: String = "CodeForcesRatingsInfoQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CodeForcesRatingsInfoQuery($username: String!) { getCodeForcesUser(username: $username) { __typename result { __typename ratings { __typename contestId contestName handle rank ratingUpdateTimeSeconds oldRating newRating } } } }"#
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
      .field("getCodeForcesUser", GetCodeForcesUser?.self, arguments: ["username": .variable("username")]),
    ] }

    ///  Query to fetch CodeForces user data by username
    public var getCodeForcesUser: GetCodeForcesUser? { __data["getCodeForcesUser"] }

    /// GetCodeForcesUser
    ///
    /// Parent Type: `CodeForcesUser`
    public struct GetCodeForcesUser: KontestGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeForcesUser }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("result", Result?.self),
      ] }

      public var result: Result? { __data["result"] }

      /// GetCodeForcesUser.Result
      ///
      /// Parent Type: `CodeForcesUserInfo`
      public struct Result: KontestGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeForcesUserInfo }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("ratings", [Rating]?.self),
        ] }

        ///  Basic information about the user
        public var ratings: [Rating]? { __data["ratings"] }

        /// GetCodeForcesUser.Result.Rating
        ///
        /// Parent Type: `CodeForcesUserRating`
        public struct Rating: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeForcesUserRating }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("contestId", Int.self),
            .field("contestName", String.self),
            .field("handle", String.self),
            .field("rank", Int.self),
            .field("ratingUpdateTimeSeconds", Int.self),
            .field("oldRating", Int.self),
            .field("newRating", Int.self),
          ] }

          public var contestId: Int { __data["contestId"] }
          public var contestName: String { __data["contestName"] }
          public var handle: String { __data["handle"] }
          public var rank: Int { __data["rank"] }
          public var ratingUpdateTimeSeconds: Int { __data["ratingUpdateTimeSeconds"] }
          public var oldRating: Int { __data["oldRating"] }
          public var newRating: Int { __data["newRating"] }
        }
      }
    }
  }
}
