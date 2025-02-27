

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: Float? // Делаем Float? (опциональный)
    let imageURL: URL
    
    var resizedImageURL: URL {
        let urlString = imageURL.absoluteString
        if let index = urlString.range(of: "._")?.lowerBound {
            let baseURL = urlString[..<index]
            let newURLString = baseURL + "._V0_UX600_.jpg"
            if let newURL = URL(string: String(newURLString)) {
                return newURL
            }
        }
        return imageURL
    }

    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        imageURL = try container.decode(URL.self, forKey: .imageURL)

        // Преобразуем рейтинг из строки в число
        if let ratingString = try? container.decode(String.self, forKey: .rating),
           let ratingFloat = Float(ratingString) {
            rating = ratingFloat
        } else {
            rating = nil
        }
    }
}
