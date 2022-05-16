//
//  CommonBackendType.swift
//  fieldBy
//
//  Created by 박진서 on 2022/05/03.
//

import RxSwift
import RxCocoa
import NSObject_Rx
import Alamofire
import FirebaseDatabase

class CommonBackendType: NSObject {
    
    static let baseUrl = "https://fieldby-web-default-rtdb.asia-southeast1.firebasedatabase.app"

    static func decode<T: Decodable>(jsonData: Data, type: T.Type) -> T? {
        do {
            let data = try JSONDecoder().decode(type.self, from: jsonData)
            return data
        } catch {
            return nil
        }
    }
    
    static func parseParams(baseUrl: String = baseUrl, path: String, params: [String: Any] = ["print":"pretty"]) -> String {
        let queryParams = params.map { k, v in "\(k)=\(v)" }.joined(separator: "&")
        var fullPath = path.hasPrefix("http") ? path : self.baseUrl + path + ".json"
        if !queryParams.isEmpty {
            fullPath += "?" + queryParams
        }
        
        return fullPath
    }
    
    static func getRequest(_ url: URL, method: HTTPMethod = .get) -> URLRequest {
        var request = URLRequest(url: url)
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        return request
    }
    
    static func single<T: Codable>(baseUrl: String = baseUrl, path: String, type: T.Type, params: [String: Any] = ["print":"pretty"], body: [String: Any] = [:], method: HTTPMethod = .get) -> Single<T> {
        
        return Single.create() { observable in
            let fullPath = self.parseParams(baseUrl: baseUrl, path: path, params: params)

            guard let url = URL(string: fullPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
//                observable(.error(DatabaseFetchingErrorType.urlFailedError))
                return Disposables.create()
            }
            
            var request = self.getRequest(url, method: method)
            
            if method != .get {
                let jsonData = try! JSONSerialization.data(withJSONObject: body)
                request.httpBody = jsonData
            }

            AF.request(request)
                .validate(statusCode: 200..<300)
                .responseData { response in
                switch response.result {
                case .success(let data):
                    if let returnData = self.decode(jsonData: data, type: type.self) {
                        observable(.success(returnData))
                        print("🆗 [\(type)] fetching 성공")
                    } else {
                        print("🚫 [\(type)] Decode 실패")
//                        observable(.error(DatabaseFetchingErrorType.encodingFailedError))
                    }

                case .failure(let err):
                    print("🚫[\(type)] 에러 \(err)")
//                    observable(.error(DatabaseFetchingErrorType.fetchingFailedError))
                }
            }
            return Disposables.create()
        }
    }
    
    static func voidPost(path: String, key: String, value: Any) {
        Database.database().reference().child(path).child(key).setValue(value)
    }
    
    static func simplePost(path: String, body: Any) -> Completable {
        return Completable.create() { completable in
            
            let fullPath = Database.database().reference().child(path)
                        
            fullPath.setValue(body) { error, ref in
                if let error = error {
                    print(error)
                    completable(.error(error))
                } else {
                    print(ref)
                    completable(.completed)
                }
            }
            
            return Disposables.create()
        }
    }
    
    static func objectPost(path: String, body: Encodable) -> Completable {
        return Completable.create() { completable in
            
            let fullPath = Database.database().reference().child(path)
            
            fullPath.setValue(body) { error, ref in
                if let error = error {
                    print(error)
                    completable(.error(error))
                } else {
                    print(ref)
                    completable(.completed)
                }
            }
            
            return Disposables.create()
        }
    }
    
    
}
