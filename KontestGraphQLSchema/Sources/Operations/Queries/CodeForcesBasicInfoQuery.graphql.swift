// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CodeForcesBasicInfoQuery: GraphQLQuery {
  public static let operationName: String = "CodeForcesBasicInfoQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CodeForcesBasicInfoQuery($username: String!) { getCodeForcesUser(username: $username) { __typename result { __typename basicInfo { __typename contribution lastOnlineTimeSeconds friendOfCount titlePhoto handle avatar registrationTimeSeconds rating maxRating rank maxRank } } } }"#
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
          .field("basicInfo", BasicInfo?.self),
        ] }

        public var basicInfo: BasicInfo? { __data["basicInfo"] }

        /// GetCodeForcesUser.Result.BasicInfo
        ///
        /// Parent Type: `CodeForcesUserBasicInfo`
        public struct BasicInfo: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeForcesUserBasicInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("contribution", Int.self),
            .field("lastOnlineTimeSeconds", Int.self),
            .field("friendOfCount", Int.self),
            .field("titlePhoto", String.self),
            .field("handle", String.self),
            .field("avatar", String.self),
            .field("registrationTimeSeconds", Int.self),
            .field("rating", Int?.self),
            .field("maxRating", Int?.self),
            .field("rank", String?.self),
            .field("maxRank", String?.self),
          ] }

          public var contribution: Int { __data["contribution"] }
          public var lastOnlineTimeSeconds: Int { __data["lastOnlineTimeSeconds"] }
          public var friendOfCount: Int { __data["friendOfCount"] }
          public var titlePhoto: String { __data["titlePhoto"] }
          public var handle: String { __data["handle"] }
          public var avatar: String { __data["avatar"] }
          public var registrationTimeSeconds: Int { __data["registrationTimeSeconds"] }
          public var rating: Int? { __data["rating"] }
          public var maxRating: Int? { __data["maxRating"] }
          public var rank: String? { __data["rank"] }
          public var maxRank: String? { __data["maxRank"] }
        }
      }
    }
  }
}
