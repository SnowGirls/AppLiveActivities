
import SwiftUI
import ActivityKit

struct DeliveryTrackAttributes: ActivityAttributes, Identifiable {
    var id = UUID()
    
    public typealias LiveDeliveryData = ContentState
    
    public struct ContentState: Codable, Hashable {
        var courierName: String
        var progress: Int           // [0 - 120]
        var deliveryTime: Date
    }
    
    var numberOfGroceryItems: Int
}
