import UIKit

final class GroceryCollectionCell: UICollectionViewCell {
  static let reuseIdentifier = "GroceryCollectionCell"

  private var item: GroceryItem?
  private var list: GroceryList?

  override init(frame: CGRect) {
    super.init(frame: frame)

    layer.cornerRadius = 14
    layer.cornerCurve = .continuous
    clipsToBounds = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func configure(item: GroceryItem, list: GroceryList) {
    self.item = item
    self.list = list
    setNeedsUpdateConfiguration()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    guard let item, let list else { return }

    let done = item.isDone
    backgroundColor = done ? .secondarySystemGroupedBackground : .systemBackground

    var content = UIListContentConfiguration.cell()
    content.image = UIImage(systemName: done ? "checkmark.circle.fill" : "circle")
    content.imageProperties.tintColor = done ? .systemGreen : .tertiaryLabel
    content.text = item.title
    content.textProperties.font = .preferredFont(forTextStyle: .headline)
    content.textProperties.color = done ? .secondaryLabel : .label
    content.textProperties.numberOfLines = 2
    content.secondaryText = list.showsDetails ? item.detail : nil
    content.secondaryTextProperties.color = done ? .tertiaryLabel : .secondaryLabel
    content.secondaryTextProperties.numberOfLines = 2
    contentConfiguration = content
  }
}
