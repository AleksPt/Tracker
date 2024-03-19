import UIKit

final class TrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    private let settingsConstraintsCell: CollectionSettings = CollectionSettings(
        cellsQuantity: 2,
        rightInset: 16,
        leftInset: 16,
        cellSpacing: 9
    )
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var dataManager = MocksTracker.mocksTrackers
    
    //MARK: - UI
    private lazy var stubImageView: UIImageView = {
        let image = UIImage(named: "StubImage")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var noSearchImageView: UIImageView = {
        let image = UIImage(named: "noInfoImage")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var noSearchLabel: UILabel = {
        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var searchBar: UISearchTextField = {
        let textField = UISearchTextField()
        textField.textColor = .ypBlack
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Поиск"
        textField.backgroundColor = .clear
        textField.delegate = self
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")
        picker.calendar.firstWeekday = 2
        picker.clipsToBounds = true
        picker.tintColor = .ypBlue
        picker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        picker.heightAnchor.constraint(equalToConstant: 34).isActive = true
        picker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier
        )
        collectionView.register(
            TrackerCollectionViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCollectionViewHeader.identifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addTapGestureToHideKeyboard()
        trackersCollectionView.delegate = self
        trackersCollectionView.dataSource = self
        view.backgroundColor = .ypWhite
        setupView()
        navBarItem()
        setupConstraints()
        reloadData()
        conditionStubs()
    }
    
    // MARK: - Private Methods
    private func conditionStubs() {
        if !visibleCategories.isEmpty {
            stubLabel.isHidden = true
            stubImageView.isHidden = true
            noSearchImageView.isHidden = true
            noSearchLabel.isHidden = true
            trackersCollectionView.isHidden = false
        } else {
            trackersCollectionView.isHidden = true
            stubLabel.isHidden = false
            stubImageView.isHidden = false
        }
    }
    
    private func reloadPlaceholder() {
        if !categories.isEmpty && visibleCategories.isEmpty {
            noSearchImageView.isHidden = false
            noSearchLabel.isHidden = false
            stubLabel.isHidden = true
            stubImageView.isHidden = true
        } else {
            noSearchImageView.isHidden = true
            noSearchLabel.isHidden = true
        }
    }
    
    private func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor))
        constraints.append(trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor))
        constraints.append(trackersCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 34))
        constraints.append(trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        
        constraints.append(noSearchImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(noSearchImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor))
        
        constraints.append(stubLabel.centerXAnchor.constraint(equalTo: stubImageView.centerXAnchor))
        constraints.append(stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8))
        
        constraints.append(noSearchLabel.centerXAnchor.constraint(equalTo: noSearchImageView.centerXAnchor))
        constraints.append(noSearchLabel.topAnchor.constraint(equalTo: noSearchImageView.bottomAnchor, constant: 8))
        
        constraints.append(searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        constraints.append(searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16))
        constraints.append(searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16))
        constraints.append(searchBar.heightAnchor.constraint(equalToConstant: 36))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupView(){
        view.addSubview(trackersCollectionView)
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
        view.addSubview(searchBar)
        view.addSubview(noSearchImageView)
        view.addSubview(noSearchLabel)
        noSearchImageView.isHidden = true
        noSearchLabel.isHidden = true
    }
    
    private func navBarItem() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "Трекеры"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        
        let leftButton = UIBarButtonItem(
            image: UIImage(named: "PlusTask"),
            style: .plain,
            target: self,
            action: #selector(Self.didTapButton))
        leftButton.tintColor = .ypBlack
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = rightButton
    }
    
    private func reloadVisibleCategories() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        let filterText = (searchBar.text ?? "").lowercased()
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackerArray.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.contains { weekDay in
                    weekDay.calendarDayNumber == filterWeekday
                } == true
                return textCondition && dateCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                headerName: category.headerName,
                trackerArray: trackers)
        }
        trackersCollectionView.reloadData()
        conditionStubs()
    }
    
    private func reloadVisibleCategoriesSearch() {
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: datePicker.date)
        let filterText = (searchBar.text ?? "").lowercased()
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackerArray.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                let dateCondition = tracker.schedule.contains { weekDay in
                    weekDay.calendarDayNumber == filterWeekday
                } == true
                return textCondition && dateCondition
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                headerName: category.headerName,
                trackerArray: trackers)
        }
        trackersCollectionView.reloadData()
        reloadPlaceholder()
    }
    
    private func reloadData() {
        //categories = dataManager
        datePickerValueChanged()
    }
    
    // MARK: - Objc Methods:
    @objc private func didTapButton() {
        let viewController = CreateTypeTrackerViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    @objc private func datePickerValueChanged() {
        noSearchImageView.isHidden = true
        noSearchLabel.isHidden = true
        reloadVisibleCategories()
    }
}

// MARK: - UISearchBarDelegate
extension TrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        reloadVisibleCategoriesSearch()
        return true
    }
}

// MARK: - UICollectionViewDelegateFlowLayout:
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.frame.size.width - settingsConstraintsCell.paddingWidth
        let cellWidth = availableWidth / CGFloat(settingsConstraintsCell.cellsQuantity)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: settingsConstraintsCell.leftInset, bottom: 11, right: settingsConstraintsCell.rightInset)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let header = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath
        )
        let headerSize = header.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
        return headerSize
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        settingsConstraintsCell.cellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}

// MARK: - UICollectionViewDataSource:
extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        visibleCategories[section].trackerArray.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else { return UICollectionViewCell()}
        cell.delegate = self
        let tracker = visibleCategories[indexPath.section].trackerArray[indexPath.row]
        let isCompleted = completedTrackers.contains { record in
            record.id == tracker.id && record.date.onlyDate == datePicker.date.onlyDate }
        let isEnabled = datePicker.date <= Date() || Date().onlyDate == datePicker.date.onlyDate
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        cell.cellSettings(
            id: tracker.id,
            name: tracker.name,
            color: tracker.color,
            emoji: tracker.emoji,
            completedDays: completedDays,
            isEnabled: isEnabled,
            isCompleted: isCompleted,
            indexPath: indexPath)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if let cell = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerCollectionViewHeader.identifier,
            for: indexPath
        ) as? TrackerCollectionViewHeader {
            cell.titleLabel.font = .boldSystemFont(ofSize: 19)
            cell.titleLabel.text = visibleCategories[indexPath.section].headerName
            return cell
        } else {
            return UICollectionReusableView()
        }
    }
}

//MARK: - CreateTypeTrackerDelegate:
extension TrackerViewController: CreateTypeTrackerDelegate {
    func plusTracker(
        _ tracker: Tracker,
        _ category: String,
        from: CreateTypeTrackerViewController
    ) {
        var updatedCategory: TrackerCategory?
        var index: Int?
        for i in 0..<categories.count {
            if categories[i].headerName == category {
                updatedCategory = categories[i]
                index = i
            }
        }
        if updatedCategory == nil {
            categories.append(TrackerCategory(headerName: category, trackerArray: [tracker]))
        } else {
            let newOnTrackers = (updatedCategory?.trackerArray ?? []) + [tracker]
            let sortedOnTrackers = newOnTrackers.sorted { $0.name < $1.name }
            let newCategory = TrackerCategory(headerName: category, trackerArray: sortedOnTrackers)
            categories.remove(at: index ?? 0)
            categories.insert(newCategory, at: index ?? 0)
        }
        visibleCategories = categories
        reloadVisibleCategories()
        trackersCollectionView.reloadData()
    }
}

// MARK: - TrackerCellDelegate:
extension TrackerViewController: TrackerCellDelegate {
    func trackerCompleted(for id: UUID, at indexPath: IndexPath) {
        if let index = completedTrackers.firstIndex(where: { tracker in
            tracker.id == id && tracker.date.onlyDate == datePicker.date.onlyDate
        }) {
            completedTrackers.remove(at: index)
        } else {
            completedTrackers.append(TrackerRecord(id: id, date: datePicker.date))
        }
        trackersCollectionView.reloadItems(at: [indexPath])
    }
}
