import UIKit

struct Todo: Codable, Equatable {
    let id: Int
    var isDone: Bool
    var detail: String
    var isToday: Bool
    
    // update 로직 추가
    mutating func update(isDone: Bool, detail: String, isToday: Bool) {
        self.isDone = isDone
        self.detail = detail
        self.isToday = isToday
    }
    
    // 동등 조건 추가, Equatable 프로토콜을 따라야 함
    // lhs - leftHandSide / rhs - rightHandSide
    static func == (lhs: Self, rhs: Self) -> Bool {
        
        // 각각의 todo id가 같으면 같은 id
        return lhs.id == rhs.id
    }
}

// 여러 개의 todo를 관리
// todoViewModel이 접근해서 사용
class TodoManager {
    static let shared = TodoManager() // 싱글톤
    static var lastId: Int = 0
    var todos: [Todo] = []
    
    // create 로직 추가
    func createTodo(detail: String, isToday: Bool) -> Todo {
        
        // 새로운 id 생성
        let nextId = TodoManager.lastId + 1
        TodoManager.lastId = nextId
        return Todo(id: nextId, isDone: false, detail: detail, isToday: isToday)
    }
    
    // add 로직 추가
    func addTodo(_ todo: Todo) {
        todos.append(todo)
        saveTodo()
    }
    
    // delete 로직 추가
    func deleteTodo(_ todo: Todo) {
        todos = todos.filter { $0.id != todo.id}
        saveTodo()
    }
    
    // update 로직 추가
    func updateTodo(_ todo: Todo) {
        guard let index = todos.firstIndex(of: todo) else { return }
        todos[index].update(isDone: todo.isDone, detail: todo.detail, isToday: todo.isToday)
        saveTodo()
    }
    
    // save 로직 추가
    func saveTodo() {
        Storage.store(todos, to: .documents, as: "todos.json")
    }
    
    func retrieveTodo() {
        todos = Storage.retrive("todos.json", from: .documents, as: [Todo].self) ?? []
        
        let lastId = todos.last?.id ?? 0
        TodoManager.lastId = lastId
    }
}

class TodoViewModel {
    
    enum Section: Int, CaseIterable {
        case today
        case upcomming
        
        var title: String {
            switch self {
            case .today: return "Today"
            default: return "Upcomming"
            }
        }
    }
    
    private let manager = TodoManager.shared
    
    var todos: [Todo] {
        return manager.todos
    }
    
    var todayTodos: [Todo] {
        return todos.filter { $0.isToday == true }
    }
    
    var upcommingTodos: [Todo] {
        return todos.filter { $0.isToday == false }
    }
    
    // 전체 case의 개수를 넘겨줌
    var numOfSection: Int {
        return Section.allCases.count
    }
    
    func addTodo(_ todo: Todo) {
        manager.addTodo(todo)
    }
    
    func deleteTodo(_ todo: Todo) {
        manager.deleteTodo(todo)
    }
    
    func updateTodo(_ todo: Todo) {
        manager.updateTodo(todo)
    }
    
    func loadTasks() {
        manager.retrieveTodo()
    }
}
