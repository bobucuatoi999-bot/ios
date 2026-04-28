import UIKit

class SplashViewController: UIViewController {

    private let primaryColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.navigateToMain()
        }
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Logo image
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.contentMode = .scaleAspectFit

        // App name label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Hệ Thống Tưới Thông Minh"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(red: 33/255, green: 82/255, blue: 123/255, alpha: 1)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        let stack = UIStackView(arrangedSubviews: [logoImageView, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 260),
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func navigateToMain() {
        let mainVC = MainViewController()
        let transition = CATransition()
        transition.duration = 0.4
        transition.type = .fade

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.layer.add(transition, forKey: kCATransition)
            window.rootViewController = mainVC
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
}
