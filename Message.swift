
import Foundation
import UIKit

class Message {
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func set(fromId: String, text: String, timestamp:NSNumber?, toId: String){
        self.fromId = fromId
        self.text = text
        self.timestamp = timestamp
        self.toId = toId
    }
}

