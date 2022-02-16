import Foundation

@available(macOS 12.0, *)
class SimpleRemote<A> {
    let parse: (Data) throws -> A
    let url: URL
    
    init(url: URL, parse: @escaping (Data) throws -> A) {
        self.url = url
        self.parse = parse
    }
        
    @available(iOS 15.0, *)
    func load() async throws -> A {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw SimpleRemoteError.unknown
        }

        return try parse(data)
    }
}

@available(macOS 12.0, *)
extension SimpleRemote where A: Decodable {
    convenience init(url: URL) {
        self.init(url: url, parse: {
            try JSONDecoder().decode(A.self, from: $0)
        })
    }
}
