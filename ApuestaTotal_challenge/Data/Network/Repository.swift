//
//  Repository.swift
//  ApuestaTotal_challenge
//
//  Created by Jet Li Jesús Herrera Huaraz on 17/03/26.
//

import Foundation

protocol BaseRepositoryProtocol {
    func request<T: Decodable>(
        endpoint: APIEndpoint,
        model: T.Type,
        completion: @escaping (Result<T, CustomError>) -> Void
    )
}

class BaseRepository: BaseRepositoryProtocol {
    private let baseURL = AppConfig.baseURL
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(
        endpoint: APIEndpoint,
        model: T.Type,
        completion: @escaping (Result<T, CustomError>) -> Void
    ) {
        let urlString = baseURL + endpoint.path

        print("******************** URL: \(urlString) ********************")
        print("******************** METHOD: \(endpoint.method.rawValue) ********************")

        guard let urlRequest = buildRequest(urlString: urlString, endpoint: endpoint) else {
            completion(.failure(.errorUnknown))
            return
        }

        session.dataTask(with: urlRequest) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            let statusCode = httpResponse?.statusCode ?? 0

            if let data = data, let jsonString = String(data: data, encoding: .utf8) {
                print("******************** RESPONSE JSON ********************")
                print(jsonString)
                print("******************************************************")
            }

            // Network Error
            if let error = error {
                print("Network error: \(error.localizedDescription)")

                if let urlError = error as? URLError,
                   urlError.code == .notConnectedToInternet {
                    completion(.failure(.networkUnavailable))
                } else {
                    completion(.failure(.errorUnknown))
                }
                return
            }

            // Status code 200..<300
            guard (200..<300).contains(statusCode) else {
                completion(.failure(.errorServer(statusCode: statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.errorUnknown))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.errorDecoding))
            }
        }.resume()
    }

    // MARK: - Private

    private func buildRequest(urlString: String, endpoint: APIEndpoint) -> URLRequest? {
        guard var components = URLComponents(string: urlString) else { return nil }

        let method = endpoint.method.rawValue.uppercased()

        // Parametters for GET
        if method == "GET", let parameters = endpoint.parameters {
            components.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }

        guard let url = components.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Parametteres for POST/PUT/PATCH
        if method != "GET", let parameters = endpoint.parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }

        return request
    }
}
