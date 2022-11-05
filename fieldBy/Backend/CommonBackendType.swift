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
import FirebaseStorage

class CommonBackendType: NSObject {
    
    static let baseUrl = "https://fieldby-web-default-rtdb.asia-southeast1.firebasedatabase.app"
    
    let ref = Database.database().reference()
    let storageRef = Storage.storage().reference()
    
    func parseParams(baseUrl: String = baseUrl, path: String, params: [String: Any] = ["print":"pretty"]) -> String {
        let queryParams = params.map { k, v in "\(k)=\(v)" }.joined(separator: "&")
        var fullPath = path.hasPrefix("http") ? path : baseUrl + path + ".json"
        if !queryParams.isEmpty {
            fullPath += "?" + queryParams
        }
        
        return fullPath
    }
    
    func decode<T: Decodable>(jsonData: Data, type: T.Type) -> T? {
        do {
            let data = try JSONDecoder().decode(type.self, from: jsonData)
            return data
        } catch {
            return nil
        }
        
    }
    
    static func getRequest(_ url: URL, method: HTTPMethod = .get) -> URLRequest {
        var request = URLRequest(url: url)
        request.method = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 10
        
        return request
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
    
    func getSingle<T: Decodable>(url: String, type: T.Type) -> Single<T> {
        return Single.create() { single in
            AF.request(url, method: .get)
                .validate(statusCode: 200..<300)
                .responseData { [unowned self] response in
                    switch response.result {
                    case .success(let data):
                        if let data = decode(jsonData: data, type: T.self) {
                            single(.success(data))
                        } else {
                            single(.error(FetchError.decodingFailed))
                        }
                    case .failure(let error):
                        single(.error(error))
                    }
                }
            return Disposables.create()
        }
    }
    
}
