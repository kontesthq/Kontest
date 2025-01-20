// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class AllThingsQuery: GraphQLQuery {
  public static let operationName: String = "AllThings"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query AllThings { kontestQuery { __typename health supportedSites kontests(page: 1, perPage: 10) { __typename ... on Kontests { kontests { __typename endTime location name startTime url } } ... on KontestError { message } } } codeChefQuery { __typename getCodeChefUser(username: "ayushs_2k4") { __typename success profile name currentRating highestRating countryFlag countryName globalRank countryRank stars heatMap { __typename date value } } getUserKontestHistory(username: "ayushs_2k4") { __typename code year month day reason penalisedIn rating rank name endDate color } } getCodeForcesUser(username: "ayushsinghals") { __typename result { __typename ratings { __typename contestId contestName handle newRating oldRating rank ratingUpdateTimeSeconds } basicInfo { __typename avatar contribution friendOfCount handle lastOnlineTimeSeconds maxRank maxRating rank rating registrationTimeSeconds titlePhoto } } } leetcodeQuery { __typename activeDailyCodingChallengeQuestion { __typename date link userStatus question { __typename acRate difficulty freqBar hasSolution hasVideoSolution isFavor isPaidOnly questionFrontendId status title titleSlug topicTags { __typename id name slug } } } matchedUser(username: "ayushs_2k4") { __typename githubUrl linkedinUrl twitterUrl username contestBadge { __typename expired hoverText icon name } languageProblemCount { __typename languageName problemsSolved } problemsSolvedBeatsStats { __typename difficulty percentage } submitStatsGlobal { __typename acSubmissionNum { __typename count difficulty } } profile { __typename aboutMe categoryDiscussCount categoryDiscussCountDiff company countryName jobTitle postViewCount postViewCountDiff ranking realName reputation reputationDiff school skillTags solutionCount solutionCountDiff userAvatar websites } } userContestRanking(username: "ayushs_2k4") { __typename attendedContestsCount globalRanking rating topPercentage totalParticipants badge { __typename name } } userContestRankingHistory(username: "ayushs_2k4") { __typename attended finishTimeInSeconds problemsSolved ranking rating totalProblems trendDirection contest { __typename startTime title } } } }"#
    ))

  public init() {}

  public struct Data: KontestGraphQLSchema.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("kontestQuery", KontestQuery?.self),
      .field("codeChefQuery", CodeChefQuery?.self),
      .field("getCodeForcesUser", GetCodeForcesUser?.self, arguments: ["username": "ayushsinghals"]),
      .field("leetcodeQuery", LeetcodeQuery?.self),
    ] }

    public var kontestQuery: KontestQuery? { __data["kontestQuery"] }
    public var codeChefQuery: CodeChefQuery? { __data["codeChefQuery"] }
    ///  Query to fetch CodeForces user data by username
    public var getCodeForcesUser: GetCodeForcesUser? { __data["getCodeForcesUser"] }
    public var leetcodeQuery: LeetcodeQuery? { __data["leetcodeQuery"] }

    /// KontestQuery
    ///
    /// Parent Type: `KontestQuery`
    public struct KontestQuery: KontestGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.KontestQuery }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("health", String?.self),
        .field("supportedSites", [String?]?.self),
        .field("kontests", Kontests?.self, arguments: [
          "page": 1,
          "perPage": 10
        ]),
      ] }

      public var health: String? { __data["health"] }
      public var supportedSites: [String?]? { __data["supportedSites"] }
      public var kontests: Kontests? { __data["kontests"] }

      /// KontestQuery.Kontests
      ///
      /// Parent Type: `KontestsResult`
      public struct Kontests: KontestGraphQLSchema.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Unions.KontestsResult }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsKontests.self),
          .inlineFragment(AsKontestError.self),
        ] }

        public var asKontests: AsKontests? { _asInlineFragment() }
        public var asKontestError: AsKontestError? { _asInlineFragment() }

        /// KontestQuery.Kontests.AsKontests
        ///
        /// Parent Type: `Kontests`
        public struct AsKontests: KontestGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AllThingsQuery.Data.KontestQuery.Kontests
          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.Kontests }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("kontests", [Kontest?]?.self),
          ] }

          public var kontests: [Kontest?]? { __data["kontests"] }

          /// KontestQuery.Kontests.AsKontests.Kontest
          ///
          /// Parent Type: `Kontest`
          public struct Kontest: KontestGraphQLSchema.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.Kontest }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("endTime", String?.self),
              .field("location", String?.self),
              .field("name", String?.self),
              .field("startTime", String?.self),
              .field("url", String?.self),
            ] }

            public var endTime: String? { __data["endTime"] }
            public var location: String? { __data["location"] }
            public var name: String? { __data["name"] }
            public var startTime: String? { __data["startTime"] }
            public var url: String? { __data["url"] }
          }
        }

        /// KontestQuery.Kontests.AsKontestError
        ///
        /// Parent Type: `KontestError`
        public struct AsKontestError: KontestGraphQLSchema.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = AllThingsQuery.Data.KontestQuery.Kontests
          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.KontestError }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("message", String?.self),
          ] }

          public var message: String? { __data["message"] }
        }
      }
    }

    /// CodeChefQuery
    ///
    /// Parent Type: `CodeChefQuery`
    public struct CodeChefQuery: KontestGraphQLSchema.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeChefQuery }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("getCodeChefUser", GetCodeChefUser?.self, arguments: ["username": "ayushs_2k4"]),
        .field("getUserKontestHistory", [GetUserKontestHistory?]?.self, arguments: ["username": "ayushs_2k4"]),
      ] }

      public var getCodeChefUser: GetCodeChefUser? { __data["getCodeChefUser"] }
      public var getUserKontestHistory: [GetUserKontestHistory?]? { __data["getUserKontestHistory"] }

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
          .field("heatMap", [HeatMap].self),
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
        public var heatMap: [HeatMap] { __data["heatMap"] }

        /// CodeChefQuery.GetCodeChefUser.HeatMap
        ///
        /// Parent Type: `HeatMapEntry`
        public struct HeatMap: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.HeatMapEntry }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("date", String.self),
            .field("value", Int.self),
          ] }

          public var date: String { __data["date"] }
          ///  The date of the heat map entry
          public var value: Int { __data["value"] }
        }
      }

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
          .field("basicInfo", BasicInfo?.self),
        ] }

        ///  Basic information about the user
        public var ratings: [Rating]? { __data["ratings"] }
        public var basicInfo: BasicInfo? { __data["basicInfo"] }

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
            .field("newRating", Int.self),
            .field("oldRating", Int.self),
            .field("rank", Int.self),
            .field("ratingUpdateTimeSeconds", Int.self),
          ] }

          public var contestId: Int { __data["contestId"] }
          public var contestName: String { __data["contestName"] }
          public var handle: String { __data["handle"] }
          public var newRating: Int { __data["newRating"] }
          public var oldRating: Int { __data["oldRating"] }
          public var rank: Int { __data["rank"] }
          public var ratingUpdateTimeSeconds: Int { __data["ratingUpdateTimeSeconds"] }
        }

        /// GetCodeForcesUser.Result.BasicInfo
        ///
        /// Parent Type: `CodeForcesUserBasicInfo`
        public struct BasicInfo: KontestGraphQLSchema.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { KontestGraphQLSchema.Objects.CodeForcesUserBasicInfo }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("__typename", String.self),
            .field("avatar", String.self),
            .field("contribution", Int.self),
            .field("friendOfCount", Int.self),
            .field("handle", String.self),
            .field("lastOnlineTimeSeconds", Int.self),
            .field("maxRank", String?.self),
            .field("maxRating", Int?.self),
            .field("rank", String?.self),
            .field("rating", Int?.self),
            .field("registrationTimeSeconds", Int.self),
            .field("titlePhoto", String.self),
          ] }

          public var avatar: String { __data["avatar"] }
          public var contribution: Int { __data["contribution"] }
          public var friendOfCount: Int { __data["friendOfCount"] }
          public var handle: String { __data["handle"] }
          public var lastOnlineTimeSeconds: Int { __data["lastOnlineTimeSeconds"] }
          public var maxRank: String? { __data["maxRank"] }
          public var maxRating: Int? { __data["maxRating"] }
          public var rank: String? { __data["rank"] }
          public var rating: Int? { __data["rating"] }
          public var registrationTimeSeconds: Int { __data["registrationTimeSeconds"] }
          public var titlePhoto: String { __data["titlePhoto"] }
        }
      }
    }

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
        .field("matchedUser", MatchedUser?.self, arguments: ["username": "ayushs_2k4"]),
        .field("userContestRanking", UserContestRanking?.self, arguments: ["username": "ayushs_2k4"]),
        .field("userContestRankingHistory", [UserContestRankingHistory?]?.self, arguments: ["username": "ayushs_2k4"]),
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
          .field("userStatus", String?.self),
          .field("question", Question?.self),
        ] }

        public var date: String? { __data["date"] }
        public var link: String? { __data["link"] }
        public var userStatus: String? { __data["userStatus"] }
        public var question: Question? { __data["question"] }

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
          .field("submitStatsGlobal", SubmitStatsGlobal?.self),
          .field("profile", Profile?.self),
        ] }

        public var githubUrl: String? { __data["githubUrl"] }
        public var linkedinUrl: String? { __data["linkedinUrl"] }
        public var twitterUrl: String? { __data["twitterUrl"] }
        public var username: String? { __data["username"] }
        public var contestBadge: ContestBadge? { __data["contestBadge"] }
        public var languageProblemCount: [LanguageProblemCount?]? { __data["languageProblemCount"] }
        public var problemsSolvedBeatsStats: [ProblemsSolvedBeatsStat?]? { __data["problemsSolvedBeatsStats"] }
        public var submitStatsGlobal: SubmitStatsGlobal? { __data["submitStatsGlobal"] }
        public var profile: Profile? { __data["profile"] }

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
