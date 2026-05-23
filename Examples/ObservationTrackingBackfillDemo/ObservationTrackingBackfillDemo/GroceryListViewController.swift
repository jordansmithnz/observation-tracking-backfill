import UIKit

final class GroceryListViewController: UIViewController {
  private struct LayoutSignature: Equatable {
    let usesWideRows: Bool
    let showsDetails: Bool
  }

  private let list = GroceryList()
  private let titleLabel = UILabel()
  private let summaryLabel = UILabel()
  private let buttonStack = UIStackView()
  private let headerStack = UIStackView()
  private let rootStack = UIStackView()
  private let collectionView: UICollectionView
  private var layoutSignature: LayoutSignature?

  init() {
    collectionView = UICollectionView(
      frame: .zero,
      collectionViewLayout: Self.makeLayout(usesWideRows: false, showsDetails: true)
    )
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemGroupedBackground

    titleLabel.text = "Groceries"
    titleLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(
      for: .systemFont(ofSize: 34, weight: .bold)
    )
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.textColor = .label

    summaryLabel.font = .preferredFont(forTextStyle: .subheadline)
    summaryLabel.adjustsFontForContentSizeCategory = true
    summaryLabel.textColor = .secondaryLabel

    buttonStack.axis = .horizontal
    buttonStack.spacing = 8
    buttonStack.distribution = .fillEqually
    buttonStack.addArrangedSubview(GroceryOptionButton(list: list, option: .details))
    buttonStack.addArrangedSubview(GroceryOptionButton(list: list, option: .width))

    collectionView.backgroundColor = .clear
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.alwaysBounceVertical = true
    collectionView.contentInset = .zero
    collectionView.scrollIndicatorInsets = .zero
    collectionView.contentInsetAdjustmentBehavior = .never
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.register(
      GroceryCollectionCell.self,
      forCellWithReuseIdentifier: GroceryCollectionCell.reuseIdentifier
    )

    headerStack.axis = .vertical
    headerStack.spacing = 10
    headerStack.translatesAutoresizingMaskIntoConstraints = false
    headerStack.addArrangedSubview(titleLabel)
    headerStack.addArrangedSubview(summaryLabel)
    headerStack.setCustomSpacing(14, after: summaryLabel)
    headerStack.addArrangedSubview(buttonStack)

    rootStack.axis = .vertical
    rootStack.spacing = 18
    rootStack.translatesAutoresizingMaskIntoConstraints = false
    rootStack.addArrangedSubview(headerStack)
    rootStack.addArrangedSubview(collectionView)

    view.addSubview(rootStack)
    NSLayoutConstraint.activate(
      [
        rootStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
        rootStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        rootStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        rootStack.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 1)
      ]
    )
  }

  override func updateViewConstraints() {
    super.updateViewConstraints()
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let signature = LayoutSignature(
      usesWideRows: list.usesWideRows,
      showsDetails: list.showsDetails
    )
    guard layoutSignature != signature else { return }
    layoutSignature = signature
    collectionView.setCollectionViewLayout(
      Self.makeLayout(usesWideRows: list.usesWideRows, showsDetails: list.showsDetails),
      animated: false
    )
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    summaryLabel.text = "\(list.completedCount) of \(list.items.count) groceries checked off"
  }

  private static func makeLayout(
    usesWideRows: Bool,
    showsDetails: Bool
  ) -> UICollectionViewCompositionalLayout {
    let columns = usesWideRows ? 1 : 2
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
      heightDimension: .uniformAcrossSiblings(estimate: 100)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(100)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    group.interItemSpacing = .fixed(10)

    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 10
    return UICollectionViewCompositionalLayout(section: section)
  }
}

extension GroceryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    1
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return list.items.count
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: GroceryCollectionCell.reuseIdentifier,
      for: indexPath
    ) as! GroceryCollectionCell
    cell.configure(item: list.items[indexPath.item], list: list)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    list.items[indexPath.item].isDone.toggle()
  }
}
