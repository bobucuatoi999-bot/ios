import UIKit

class OfflineView: UIView {

    var onRetry: (() -> Void)?

    private let primaryColor = UIColor(red: 21/255, green: 101/255, blue: 192/255, alpha: 1)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let emojiLabel = UILabel()
        emojiLabel.text = "📡"
        emojiLabel.font = .systemFont(ofSize: 64)
        emojiLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = "Không có kết nối mạng"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = "Vui lòng kiểm tra kết nối internet và thử lại"
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        // Fix: use UIButton.Configuration instead of deprecated contentEdgeInsets
        var config = UIButton.Configuration.filled()
        config.title = "Thử lại"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = primaryColor
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 40, bottom: 12, trailing: 40)
        config.cornerStyle = .fixed
        let retryButton = UIButton(configuration: config)
        retryButton.layer.cornerRadius = 12
        retryButton.clipsToBounds = true
        retryButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [emojiLabel, titleLabel, subtitleLabel, retryButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.setCustomSpacing(24, after: subtitleLabel)

        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32),
        ])
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}
