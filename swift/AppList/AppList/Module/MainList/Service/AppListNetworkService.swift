//
//  AppListNetworkService.swift
//  AppList
//
//  Created by ios on 2022/4/18.
//

import Foundation
import Combine

enum PaginationLoadingState {
    case idle
    case didFinish
    case loading
}

// 目前已知的问题:
// 喜欢的数据仅存本地
class AppListDataService: ObservableObject {
    
    struct Parameters: Equatable {
        var entity: String
        var limit: Int
        var term: String
    }
    enum Error: Swift.Error {
        case notFound
    }
    
    typealias CurrentLoadingInfo = (
        page: Int,
        cancelToken: AnyCancellable
    )
    @Published private(set) var list = [AppInfo]()
    
    private(set) var page = 0
    private(set) var params: Parameters
    private(set) var currentLoading: CurrentLoadingInfo?
    private(set) var loadingState: PaginationLoadingState = .idle
    
    private var requestURL = URL(string: "https://itunes.apple.com/search")!
    private lazy var isLikedAppIds = operateLocalLikedAppIds().get()
    
    init(params: Parameters) {
        self.params = params
    }
    
    //MARK:- 请求列表数据
    func reset(parameters: Parameters? = nil) {
        func update() -> Bool {
            if let parameters = parameters, parameters != self.params {
                self.params = parameters
                return true
            }
            guard let currentLoading = currentLoading else { return true }
            return currentLoading.page <= 1
        }
        if !update() { return }
        cancel()
        request(at: 1)
    }
    func next() {
        if loadingState == .loading || loadingState == .didFinish { return }
        request(at: page + 1)
    }
    func cancel() {
        guard let currentLoading = currentLoading else { return }
        currentLoading.cancelToken.cancel()
        self.currentLoading = nil
    }
    
    //MARK:- 数据更新
    func update(
        isLiked: Bool,
        at id: Int
    ) async throws {
        let filterList = list.enumerated().filter( {
            $0.element.id == id && $0.element.isLiked != isLiked
        })
        if filterList.isEmpty { throw Error.notFound }
        filterList.forEach {
            list[$0.offset] = update($0.element) {
                $0.isLiked = isLiked
            }
            if isLiked {
                isLikedAppIds.insert(id)
            }else {
                isLikedAppIds.remove(id)
            }
        }
        operateLocalLikedAppIds().save(isLikedAppIds)
    }
}

private extension AppListDataService {
    
    func update<T>(_ item: T, configure: (inout T) -> Void) -> T {
        var mItem = item
        configure(&mItem)
        return mItem
    }
    
    //MARK:- 网络请求
    func request(at page: Int) async throws {
        var cancelToken: AnyCancellable?
        
        func shouldHandle() -> Bool {
            self.currentLoading?.cancelToken == cancelToken
        }
        cancelToken = try! NetworkSession().request(
            request(page: page),
            dataType: BaseModel<[AppInfo]>.self
        ).mapError({ (error) -> Swift.Error in
            return error
        }).sink(receiveCompletion: { _ in
            if !shouldHandle() { return }
            self.currentLoading = nil
        }, receiveValue: {
            if !shouldHandle() { return }
            let list = $0.results.map { // 更新下是否喜欢
                self.isLikedAppIds.contains($0.id) ? self.update($0) {
                    $0.isLiked = true
                } : $0
            }
            self.loadingState = list.count < self.params.limit ? .didFinish : .idle
            if page <= 1 {
                self.list = list
            }else {
                self.list.append(contentsOf: list)
            }
            self.page = page
        })
        currentLoading = (page, cancelToken!)
    }
    
    func request(page: Int) -> Request {
        Request(
            url: requestURL,
            params: [
                "entity" : params.entity,
                "limit" : String(params.limit),
                "term" : params.term,
                "page" : String(page),
                "offset" : String(page <= 1 ? 0 : (list.count + 1))
            ]
        )
    }
    
    //MARK:- 本地数据处理
    typealias LikedAppIdsType = Set<Int>
    typealias LikedAppIdsOperateMethod = (
        get: () -> LikedAppIdsType,
        save: (LikedAppIdsType) -> Void
    )
    func operateLocalLikedAppIds() -> LikedAppIdsOperateMethod {
        let key = "AppListIsLikedAppIds"
        func get() -> LikedAppIdsType {
            Set((UserDefaults.standard.array(forKey: key) as? [Int]) ?? [])
        }
        func syncToDisk(likedAppIds: LikedAppIdsType) {
            UserDefaults.standard.set(Array(likedAppIds), forKey: key)
        }
        return (get, syncToDisk(likedAppIds:))
    }
}
