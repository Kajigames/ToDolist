import Foundation
import RealmSwift

class ToDoItem:Object {
    @objc dynamic var id = ""
    @objc dynamic var title = ""
    @objc dynamic var date = Date()
}
