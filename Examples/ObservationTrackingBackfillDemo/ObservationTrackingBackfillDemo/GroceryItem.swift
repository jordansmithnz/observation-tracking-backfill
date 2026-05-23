import Observation

@Observable
final class GroceryList {
  var showsDetails = true
  var usesWideRows = false
  let items = [
    GroceryItem(title: "Fuji apples", detail: "Four large apples for lunches.", isDone: true),
    GroceryItem(title: "Greek yogurt", detail: "Plain, full-fat tub."),
    GroceryItem(title: "Sourdough bread", detail: "One sliced loaf from the bakery."),
    GroceryItem(title: "Baby spinach", detail: "Washed greens for salads."),
    GroceryItem(title: "Coffee beans", detail: "Medium roast, whole bean.")
  ]

  var completedCount: Int {
    items.filter(\.isDone).count
  }
}

@Observable
final class GroceryItem {
  let title: String
  let detail: String
  var isDone: Bool

  init(title: String, detail: String, isDone: Bool = false) {
    self.title = title
    self.detail = detail
    self.isDone = isDone
  }
}
