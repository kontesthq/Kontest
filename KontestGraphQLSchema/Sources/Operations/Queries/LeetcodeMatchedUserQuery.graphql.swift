// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class LeetcodeMatchedUserQuery: GraphQLQuery {
  public static let operationName: String = "LeetcodeMatchedUserQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query LeetcodeMatchedUserQuery($username: String!) { leetcodeQuery { __typename matchedUser(username: $username) { __typename githubUrl linkedinUrl twitterUrl username contestBadge { __typename expired hoverText icon name } languageProblemCount { __typename languageName problemsSolved } problemsSolvedBeatsStats { __typename difficulty percentage } profile { __typename aboutMe categoryDiscussCount categoryDiscussCountDiff company countryName jobTitle postViewCount postViewCountDiff ranking realName reputation reputationDiff school skillTags solutionCount solutionCountDiff userAvatar websites } submitStatsGlobal { __typename acSubmissionNum { __typename count difficulty } } } } }"#
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
        .field("matchedUser", MatchedUser?.self, arguments: ["username": .variable("username")]),
      ] }

      public var matchedUser: MatchedUser? { __data["matchedUser"] }

      /// LeetcodeQuery.MatchedUser
      ///
      /// Parent Type: `MatchedUser`
      public struct MatchedUser: KontestGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.MatchedUser }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("githubUrl", String?.self),
          .field("linkedinUrl", String?.self),
          .field("twitterUrl", String?.self),
          .field("username", String?.self),
          .field("contestBadge", ContestBadge?.self),
          .field("languageProblemCount", [LanguageProblemCount?]?.self),
          .field("problemsSolvedBeatsStats", [ProblemsSolvedBeatsStat?]?.self),
          .field("profile", Profile?.self),
          .field("submitStatsGlobal", SubmitStatsGlobal?.self),
        ] }

        public var githubUrl: String? { __data["githubUrl"] }
        public var linkedinUrl: String? { __data["linkedinUrl"] }
        public var twitterUrl: String? { __data["twitterUrl"] }
        public var username: String? { __data["username"] }
        public var contestBadge: ContestBadge? { __data["contestBadge"] }
        public var languageProblemCount: [LanguageProblemCount?]? { __data["languageProblemCount"] }
        public var problemsSolvedBeatsStats: [ProblemsSolvedBeatsStat?]? { __data["problemsSolvedBeatsStats"] }
        public var profile: Profile? { __data["profile"] }
        public var submitStatsGlobal: SubmitStatsGlobal? { __data["submitStatsGlobal"] }

        /// LeetcodeQuery.MatchedUser.ContestBadge
        ///
        /// Parent Type: `ContestBadge`
        public struct ContestBadge: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.ContestBadge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("expired", Bool?.self),
            .field("hoverText", String?.self),
            .field("icon", String?.self),
            .field("name", String?.self),
          ] }

          public var expired: Bool? { __data["expired"] }
          public var hoverText: String? { __data["hoverText"] }
          public var icon: String? { __data["icon"] }
          public var name: String? { __data["name"] }
        }

        /// LeetcodeQuery.MatchedUser.LanguageProblemCount
        ///
        /// Parent Type: `LanguageProblemCount`
        public struct LanguageProblemCount: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.LanguageProblemCount }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("languageName", String?.self),
            .field("problemsSolved", Int?.self),
          ] }

          public var languageName: String? { __data["languageName"] }
          public var problemsSolved: Int? { __data["problemsSolved"] }
        }

        /// LeetcodeQuery.MatchedUser.ProblemsSolvedBeatsStat
        ///
        /// Parent Type: `ProblemSolvedBeatsStats`
        public struct ProblemsSolvedBeatsStat: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.ProblemSolvedBeatsStats }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("difficulty", String?.self),
            .field("percentage", Double?.self),
          ] }

          public var difficulty: String? { __data["difficulty"] }
          public var percentage: Double? { __data["percentage"] }
        }

        /// LeetcodeQuery.MatchedUser.Profile
        ///
        /// Parent Type: `UserProfile`
        public struct Profile: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.UserProfile }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("aboutMe", String?.self),
            .field("categoryDiscussCount", Int?.self),
            .field("categoryDiscussCountDiff", Int?.self),
            .field("company", String?.self),
            .field("countryName", String?.self),
            .field("jobTitle", String?.self),
            .field("postViewCount", Int?.self),
            .field("postViewCountDiff", Int?.self),
            .field("ranking", Int?.self),
            .field("realName", String?.self),
            .field("reputation", Int?.self),
            .field("reputationDiff", Int?.self),
            .field("school", String?.self),
            .field("skillTags", [String?]?.self),
            .field("solutionCount", Int?.self),
            .field("solutionCountDiff", Int?.self),
            .field("userAvatar", String?.self),
            .field("websites", [String?]?.self),
          ] }

          public var aboutMe: String? { __data["aboutMe"] }
          public var categoryDiscussCount: Int? { __data["categoryDiscussCount"] }
          public var categoryDiscussCountDiff: Int? { __data["categoryDiscussCountDiff"] }
          public var company: String? { __data["company"] }
          public var countryName: String? { __data["countryName"] }
          public var jobTitle: String? { __data["jobTitle"] }
          public var postViewCount: Int? { __data["postViewCount"] }
          public var postViewCountDiff: Int? { __data["postViewCountDiff"] }
          public var ranking: Int? { __data["ranking"] }
          public var realName: String? { __data["realName"] }
          public var reputation: Int? { __data["reputation"] }
          public var reputationDiff: Int? { __data["reputationDiff"] }
          public var school: String? { __data["school"] }
          public var skillTags: [String?]? { __data["skillTags"] }
          public var solutionCount: Int? { __data["solutionCount"] }
          public var solutionCountDiff: Int? { __data["solutionCountDiff"] }
          public var userAvatar: String? { __data["userAvatar"] }
          public var websites: [String?]? { __data["websites"] }
        }

        /// LeetcodeQuery.MatchedUser.SubmitStatsGlobal
        ///
        /// Parent Type: `SubmitStatsGlobal`
        public struct SubmitStatsGlobal: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.SubmitStatsGlobal }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("acSubmissionNum", [AcSubmissionNum?]?.self),
          ] }

          public var acSubmissionNum: [AcSubmissionNum?]? { __data["acSubmissionNum"] }

          /// LeetcodeQuery.MatchedUser.SubmitStatsGlobal.AcSubmissionNum
          ///
          /// Parent Type: `ACSubmissionNum`
          public struct AcSubmissionNum: KontestGraphQLSchema.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.ACSubmissionNum }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("count", Int?.self),
              .field("difficulty", String?.self),
            ] }

            public var count: Int? { __data["count"] }
            public var difficulty: String? { __data["difficulty"] }
          }
        }
      }
    }
  }
}
