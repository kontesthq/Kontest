// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CompleteLeetcodeQuery: GraphQLQuery {
  public static let operationName: String = "CompleteLeetcodeQuery"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CompleteLeetcodeQuery($username: String!) { leetcodeQuery { __typename activeDailyCodingChallengeQuestion { __typename date link question { __typename acRate difficulty freqBar hasSolution hasVideoSolution isFavor isPaidOnly questionFrontendId status title titleSlug topicTags { __typename id name slug } } userStatus } matchedUser(username: $username) { __typename githubUrl linkedinUrl twitterUrl username contestBadge { __typename expired hoverText icon name } languageProblemCount { __typename languageName problemsSolved } problemsSolvedBeatsStats { __typename difficulty percentage } profile { __typename aboutMe categoryDiscussCount categoryDiscussCountDiff company countryName jobTitle postViewCount postViewCountDiff ranking realName reputation reputationDiff school skillTags solutionCount solutionCountDiff userAvatar websites } submitStatsGlobal { __typename acSubmissionNum { __typename count difficulty } } } userContestRanking(username: $username) { __typename attendedContestsCount globalRanking rating topPercentage totalParticipants badge { __typename name } } userContestRankingHistory(username: $username) { __typename attended finishTimeInSeconds problemsSolved ranking rating totalProblems trendDirection contest { __typename startTime title } } } }"#
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
        .field("activeDailyCodingChallengeQuestion", ActiveDailyCodingChallengeQuestion?.self),
        .field("matchedUser", MatchedUser?.self, arguments: ["username": .variable("username")]),
        .field("userContestRanking", UserContestRanking?.self, arguments: ["username": .variable("username")]),
        .field("userContestRankingHistory", [UserContestRankingHistory?]?.self, arguments: ["username": .variable("username")]),
      ] }

      public var activeDailyCodingChallengeQuestion: ActiveDailyCodingChallengeQuestion? { __data["activeDailyCodingChallengeQuestion"] }
      public var matchedUser: MatchedUser? { __data["matchedUser"] }
      public var userContestRanking: UserContestRanking? { __data["userContestRanking"] }
      public var userContestRankingHistory: [UserContestRankingHistory?]? { __data["userContestRankingHistory"] }

      /// LeetcodeQuery.ActiveDailyCodingChallengeQuestion
      ///
      /// Parent Type: `DailyCodingChallengeQuestion`
      public struct ActiveDailyCodingChallengeQuestion: KontestGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.DailyCodingChallengeQuestion }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("date", String?.self),
          .field("link", String?.self),
          .field("question", Question?.self),
          .field("userStatus", String?.self),
        ] }

        public var date: String? { __data["date"] }
        public var link: String? { __data["link"] }
        public var question: Question? { __data["question"] }
        public var userStatus: String? { __data["userStatus"] }

        /// LeetcodeQuery.ActiveDailyCodingChallengeQuestion.Question
        ///
        /// Parent Type: `Question`
        public struct Question: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.Question }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("acRate", Double?.self),
            .field("difficulty", String?.self),
            .field("freqBar", String?.self),
            .field("hasSolution", Bool?.self),
            .field("hasVideoSolution", Bool?.self),
            .field("isFavor", Bool?.self),
            .field("isPaidOnly", Bool?.self),
            .field("questionFrontendId", String?.self),
            .field("status", String?.self),
            .field("title", String?.self),
            .field("titleSlug", String?.self),
            .field("topicTags", [TopicTag?]?.self),
          ] }

          public var acRate: Double? { __data["acRate"] }
          public var difficulty: String? { __data["difficulty"] }
          public var freqBar: String? { __data["freqBar"] }
          public var hasSolution: Bool? { __data["hasSolution"] }
          public var hasVideoSolution: Bool? { __data["hasVideoSolution"] }
          public var isFavor: Bool? { __data["isFavor"] }
          public var isPaidOnly: Bool? { __data["isPaidOnly"] }
          public var questionFrontendId: String? { __data["questionFrontendId"] }
          public var status: String? { __data["status"] }
          public var title: String? { __data["title"] }
          public var titleSlug: String? { __data["titleSlug"] }
          public var topicTags: [TopicTag?]? { __data["topicTags"] }

          /// LeetcodeQuery.ActiveDailyCodingChallengeQuestion.Question.TopicTag
          ///
          /// Parent Type: `TopicTag`
          public struct TopicTag: KontestGraphQLSchema.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.TopicTag }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("id", String?.self),
              .field("name", String?.self),
              .field("slug", String?.self),
            ] }

            public var id: String? { __data["id"] }
            public var name: String? { __data["name"] }
            public var slug: String? { __data["slug"] }
          }
        }
      }

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

      /// LeetcodeQuery.UserContestRanking
      ///
      /// Parent Type: `UserContestRanking`
      public struct UserContestRanking: KontestGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.UserContestRanking }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("attendedContestsCount", Int?.self),
          .field("globalRanking", Int?.self),
          .field("rating", Double?.self),
          .field("topPercentage", Double?.self),
          .field("totalParticipants", Int?.self),
          .field("badge", Badge?.self),
        ] }

        public var attendedContestsCount: Int? { __data["attendedContestsCount"] }
        public var globalRanking: Int? { __data["globalRanking"] }
        public var rating: Double? { __data["rating"] }
        public var topPercentage: Double? { __data["topPercentage"] }
        public var totalParticipants: Int? { __data["totalParticipants"] }
        public var badge: Badge? { __data["badge"] }

        /// LeetcodeQuery.UserContestRanking.Badge
        ///
        /// Parent Type: `Badge`
        public struct Badge: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.Badge }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("name", String?.self),
          ] }

          public var name: String? { __data["name"] }
        }
      }

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
