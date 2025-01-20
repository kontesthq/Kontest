// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class LeetcodeUserContestRankingHistoryQuery: GraphQLQuery {
  public static let operationName: String = "LeetcodeUserContestRankingHistoryQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query LeetcodeUserContestRankingHistoryQuery($username: String!) { leetcodeQuery { __typename userContestRankingHistory(username: $username) { __typename attended finishTimeInSeconds problemsSolved ranking rating totalProblems trendDirection contest { __typename startTime title } } } }"#
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
      .field("leetcodeQuery", LeetcodeQuery?.self),
    ] }

    public var leetcodeQuery: LeetcodeQuery? { __data["leetcodeQuery"] }

    /// LeetcodeQuery
    ///
    /// Parent Type: `LeetcodeQuery`
    public struct LeetcodeQuery: KontestGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.LeetcodeQuery }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("userContestRankingHistory", [UserContestRankingHistory?]?.self, arguments: ["username": .variable("username")]),
      ] }

      public var userContestRankingHistory: [UserContestRankingHistory?]? { __data["userContestRankingHistory"] }

      /// LeetcodeQuery.UserContestRankingHistory
      ///
      /// Parent Type: `UserContestRankingHistory`
      public struct UserContestRankingHistory: KontestGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.UserContestRankingHistory }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("attended", Bool?.self),
          .field("finishTimeInSeconds", Int?.self),
          .field("problemsSolved", Int?.self),
          .field("ranking", Int?.self),
          .field("rating", Double?.self),
          .field("totalProblems", Int?.self),
          .field("trendDirection", String?.self),
          .field("contest", Contest?.self),
        ] }

        public var attended: Bool? { __data["attended"] }
        public var finishTimeInSeconds: Int? { __data["finishTimeInSeconds"] }
        public var problemsSolved: Int? { __data["problemsSolved"] }
        public var ranking: Int? { __data["ranking"] }
        public var rating: Double? { __data["rating"] }
        public var totalProblems: Int? { __data["totalProblems"] }
        public var trendDirection: String? { __data["trendDirection"] }
        public var contest: Contest? { __data["contest"] }

        /// LeetcodeQuery.UserContestRankingHistory.Contest
        ///
        /// Parent Type: `Contest`
        public struct Contest: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.Contest }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("startTime", String?.self),
            .field("title", String?.self),
          ] }

          public var startTime: String? { __data["startTime"] }
          public var title: String? { __data["title"] }
        }
      }
    }
  }
}
