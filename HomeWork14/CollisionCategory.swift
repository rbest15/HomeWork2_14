import Foundation

struct CollisionCategory {
    let rawValue : Int
    
    static let missleCategory = CollisionCategory(rawValue: 1)
    static let targetCategory = CollisionCategory(rawValue: 2)
    static let otherCategory = CollisionCategory(rawValue: 3)
}
