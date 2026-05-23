import UIKit

final class GroceryOptionButton: UIButton {
  enum Option {
    case details
    case width
  }

  private let list: GroceryList
  private let option: Option
  private let iconView = UIImageView()
  private let textLabel = UILabel()

  init(list: GroceryList, option: Option) {
    self.list = list
    self.option = option
    super.init(frame: .zero)

    layer.cornerRadius = 8
    layer.cornerCurve = .continuous

    iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
    iconView.contentMode = .scaleAspectFit

    textLabel.font = .preferredFont(forTextStyle: .subheadline)
    textLabel.adjustsFontForContentSizeCategory = true
    textLabel.textAlignment = .center

    addSubview(iconView)
    addSubview(textLabel)
    addAction(UIAction { [weak self] _ in self?.toggle() }, for: .touchUpInside)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let selected = isOptionSelected
    backgroundColor = selected ? .systemGreen.withAlphaComponent(0.14) : .secondarySystemGroupedBackground
    iconView.image = UIImage(systemName: selected ? "checkmark.circle.fill" : "circle")
    iconView.tintColor = selected ? .systemGreen : .secondaryLabel
    textLabel.text = title
    textLabel.textColor = selected ? .systemGreen : .secondaryLabel

    let iconSize: CGFloat = 20
    let spacing: CGFloat = 6
    let textSize = textLabel.sizeThatFits(
      CGSize(width: bounds.width - iconSize - spacing - 16, height: bounds.height)
    )
    let totalWidth = iconSize + spacing + textSize.width
    let startX = max(8, (bounds.width - totalWidth) / 2)
    iconView.frame = CGRect(
      x: startX,
      y: (bounds.height - iconSize) / 2,
      width: iconSize,
      height: iconSize
    )
    textLabel.frame = CGRect(
      x: iconView.frame.maxX + spacing,
      y: 0,
      width: min(textSize.width, bounds.maxX - iconView.frame.maxX - spacing - 8),
      height: bounds.height
    )
  }

  private var isOptionSelected: Bool {
    switch option {
    case .details:
      list.showsDetails
    case .width:
      list.usesWideRows
    }
  }

  private var title: String {
    switch option {
    case .details:
      "Details"
    case .width:
      "Wide Rows"
    }
  }

  private func toggle() {
    switch option {
    case .details:
      list.showsDetails.toggle()
    case .width:
      list.usesWideRows.toggle()
    }
  }
}
