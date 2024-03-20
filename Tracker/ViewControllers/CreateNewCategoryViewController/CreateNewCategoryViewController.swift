import UIKit

final class CreateNewCategoryViewController: UIViewController {
    
    //MARK: - UI
    private var titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.tintColor = .ypWhite
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
        view.backgroundColor = .ypWhite
    }
    
    //MARK: - Private Metods
    private func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        constraints.append(titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 38))
        
        constraints.append(doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        constraints.append(doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        constraints.append(doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        
        constraints.append(doneButton.heightAnchor.constraint(equalToConstant: 60))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupView() {
        view.addSubview(titleLabel)
        view.addSubview(doneButton)
    }
    
    //MARK: - Objc Metods
    @objc private func doneButtonClicked() {
        self.dismiss(animated: true)
    }
    
}
