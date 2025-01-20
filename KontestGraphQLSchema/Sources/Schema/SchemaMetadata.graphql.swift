// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public typealias ID = String

public protocol SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == KontestGraphQLSchema.SchemaMetadata {}

public protocol InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == KontestGraphQLSchema.SchemaMetadata {}

public protocol MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == KontestGraphQLSchema.SchemaMetadata {}

public protocol MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == KontestGraphQLSchema.SchemaMetadata {}

public enum SchemaMetadata: ApolloAPI.SchemaMetadata {
  public static let configuration: ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

  public static func objectType(forTypename typename: String) -> Object? {
    switch typename {
    case "Query": return KontestGraphQLSchema.Objects.Query
    case "DailyCodingChallengeQuestion": return KontestGraphQLSchema.Objects.DailyCodingChallengeQuestion
    case "Question": return KontestGraphQLSchema.Objects.Question
    case "TopicTag": return KontestGraphQLSchema.Objects.TopicTag
    case "UserContestRanking": return KontestGraphQLSchema.Objects.UserContestRanking
    case "Badge": return KontestGraphQLSchema.Objects.Badge
    case "UserContestRankingHistory": return KontestGraphQLSchema.Objects.UserContestRankingHistory
    case "Contest": return KontestGraphQLSchema.Objects.Contest
    case "MatchedUser": return KontestGraphQLSchema.Objects.MatchedUser
    case "LanguageProblemCount": return KontestGraphQLSchema.Objects.LanguageProblemCount
    case "ContestBadge": return KontestGraphQLSchema.Objects.ContestBadge
    case "UserProfile": return KontestGraphQLSchema.Objects.UserProfile
    case "ProblemSolvedBeatsStats": return KontestGraphQLSchema.Objects.ProblemSolvedBeatsStats
    case "SubmitStatsGlobal": return KontestGraphQLSchema.Objects.SubmitStatsGlobal
    case "ACSubmissionNum": return KontestGraphQLSchema.Objects.ACSubmissionNum
    case "LeetcodeQuery": return KontestGraphQLSchema.Objects.LeetcodeQuery
    case "CodeChefQuery": return KontestGraphQLSchema.Objects.CodeChefQuery
    case "CodeChefUser": return KontestGraphQLSchema.Objects.CodeChefUser
    case "CodeChefContest": return KontestGraphQLSchema.Objects.CodeChefContest
    case "KontestQuery": return KontestGraphQLSchema.Objects.KontestQuery
    case "KontestError": return KontestGraphQLSchema.Objects.KontestError
    case "Kontests": return KontestGraphQLSchema.Objects.Kontests
    case "Kontest": return KontestGraphQLSchema.Objects.Kontest
    case "HeatMapEntry": return KontestGraphQLSchema.Objects.HeatMapEntry
    case "CodeForcesUser": return KontestGraphQLSchema.Objects.CodeForcesUser
    case "CodeForcesUserInfo": return KontestGraphQLSchema.Objects.CodeForcesUserInfo
    case "CodeForcesUserRating": return KontestGraphQLSchema.Objects.CodeForcesUserRating
    case "CodeForcesUserBasicInfo": return KontestGraphQLSchema.Objects.CodeForcesUserBasicInfo
    default: return nil
    }
  }
}

public enum Objects {}
public enum Interfaces {}
public enum Unions {}
