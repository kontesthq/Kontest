//
//  Dependencies.swift
//  Kontest
//
//  Created by Ayush Singhal on 18/09/23.
//

import FirebaseCore
import Foundation

@Observable
final class Dependencies: Sendable {
    let notificationsViewModel: NotificationsViewModel
    let filterWebsitesViewModel: FilterWebsitesViewModel
    let allKontestsViewModel: AllKontestsViewModel
    let changeUsernameViewModel: ChangeUsernameViewModel

    let leetCodeRepository: any LeetCodeGraphQLAPIFetcher = MultipleLeetCodeRepostories(repositories: [LeetCodeNewAPIGraphQLRepository(), LeetCodeAPIGraphQLRepository()])
    let codeForcesRepository: any CodeForcesFetcher = MultipleCodeForcesRepostories(repositories: [CodeForcesNewAPIRepository(), CodeForcesAPIRepository()])
    let codeChefRepository: any CodeChefFetcher = MultipleCodeChefRepostories(repositories: [CodeChefNewAPIRepository(), CodeChefAPIRepository()])

    private(set) var leetCodeGraphQLViewModel: LeetCodeGraphQLViewModel
    private(set) var codeChefViewModel: CodeChefViewModel
    private(set) var codeForcesViewModel: CodeForcesViewModel

    static let instance = Dependencies()

    private init() {
        FirebaseApp.configure()

        self.notificationsViewModel = NotificationsViewModel()
        self.filterWebsitesViewModel = FilterWebsitesViewModel()
        self.allKontestsViewModel = AllKontestsViewModel(
            notificationsViewModel: notificationsViewModel,
            filterWebsitesViewModel: filterWebsitesViewModel,
            repos: MultipleRepositories(repos: [
                AnyFetcher(KontestNewAPIRepository()),
                AnyFetcher(KontestNewRepository())
            ])
        )
        self.changeUsernameViewModel = ChangeUsernameViewModel()
        self.leetCodeGraphQLViewModel = LeetCodeGraphQLViewModel(username: changeUsernameViewModel.leetcodeUsername, repository: leetCodeRepository)
        self.codeChefViewModel = CodeChefViewModel(username: changeUsernameViewModel.codeChefUsername, codeChefAPIRepository: codeChefRepository)
        self.codeForcesViewModel = CodeForcesViewModel(username: changeUsernameViewModel.codeForcesUsername, repository: codeForcesRepository)
    }

    func changeLeetcodeUsername(leetCodeUsername: String) {
        leetCodeGraphQLViewModel = LeetCodeGraphQLViewModel(username: leetCodeUsername, repository: leetCodeRepository)
    }

    func changeCodeChefUsername(codeChefUsername: String) {
        codeChefViewModel = CodeChefViewModel(username: codeChefUsername, codeChefAPIRepository: codeChefRepository)
    }

    func changeCodeForcesUsername(codeForcesUsername: String) {
        codeForcesViewModel = CodeForcesViewModel(username: codeForcesUsername, repository: codeForcesRepository)
    }

    func reloadLeetcodeUsername() {
        leetCodeGraphQLViewModel = LeetCodeGraphQLViewModel(username: changeUsernameViewModel.leetcodeUsername, repository: leetCodeRepository)
    }

    func reloadCodeChefUsername() {
        codeChefViewModel = CodeChefViewModel(username: changeUsernameViewModel.codeChefUsername, codeChefAPIRepository: codeChefRepository)
    }

    func reloadCodeForcesUsername() {
        codeForcesViewModel = CodeForcesViewModel(username: changeUsernameViewModel.codeForcesUsername, repository: codeForcesRepository)
    }
}
