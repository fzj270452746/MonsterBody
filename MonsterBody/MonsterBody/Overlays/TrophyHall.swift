import UIKit

// MARK: - TrophyHall: Achievement Screen UIViewController
final class TrophyHall: UIViewController {
    private var tableView: UITableView!
    private var allScrolls = TrophyCatalogue.allScrolls
    private var earnedIds: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        earnedIds = Set(TroveKeeper.shared.achievementStates.filter { $0.value.isEarned }.keys)
        buildBackground()
        buildNavBar()
        buildStatsHeader()
        buildTableView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    // MARK: - Background
    private func buildBackground() {
        let grad = CAGradientLayer()
        grad.frame = view.bounds
        grad.colors = [UIColor(hex: "#1A1A2E").cgColor, UIColor(hex: "#0D0D1A").cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint = CGPoint(x: 0, y: 1)
        view.layer.insertSublayer(grad, at: 0)
    }

    // MARK: - Nav Bar
    private func buildNavBar() {
        let titleLabel = UILabel()
        titleLabel.text = "Achievements"
        titleLabel.font = UIFont(name: GlyphVault.fontHeavy, size: 22) ?? .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let closeBtn = UIButton(type: .custom)
        closeBtn.setTitle("✕", for: .normal)
        closeBtn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        closeBtn.layer.cornerRadius = 22
        closeBtn.layer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor
        closeBtn.layer.borderWidth = 1
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeBtn)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeBtn.widthAnchor.constraint(equalToConstant: 44),
            closeBtn.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    // MARK: - Stats Header
    private func buildStatsHeader() {
        let total = allScrolls.count
        let earned = earnedIds.count

        let container = UIView()
        container.backgroundColor = UIColor(white: 1, alpha: 0.07)
        container.layer.cornerRadius = 14
        container.layer.borderColor = UIColor(hex: "#FFD700").withAlphaComponent(0.3).cgColor
        container.layer.borderWidth = 1
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        let pct = total > 0 ? Int(Double(earned) / Double(total) * 100) : 0
        let statsLbl = UILabel()
        statsLbl.text = "🏆  \(earned)/\(total)  (\(pct)% complete)"
        statsLbl.font = UIFont(name: GlyphVault.fontBold, size: 15) ?? .boldSystemFont(ofSize: 15)
        statsLbl.textColor = UIColor(hex: "#FFD700")
        statsLbl.textAlignment = .center
        statsLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(statsLbl)

        // Total coins earned from achievements
        let trove = TroveKeeper.shared
        let coinLbl = UILabel()
        coinLbl.text = "Total won: \(trove.totalCoinsWonCount) coins"
        coinLbl.font = UIFont(name: GlyphVault.fontRegular, size: 12) ?? .systemFont(ofSize: 12)
        coinLbl.textColor = UIColor(white: 1, alpha: 0.55)
        coinLbl.textAlignment = .center
        coinLbl.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(coinLbl)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 58),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 60),
            statsLbl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            statsLbl.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            coinLbl.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            coinLbl.topAnchor.constraint(equalTo: statsLbl.bottomAnchor, constant: 4),
        ])
    }

    // MARK: - TableView
    private func buildTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TrophyCell.self, forCellReuseIdentifier: TrophyCell.reuseId)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 130),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc private func closeTapped() { dismiss(animated: true) }
}

// MARK: - UITableViewDataSource & Delegate
extension TrophyHall: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allScrolls.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrophyCell.reuseId, for: indexPath) as! TrophyCell
        let scroll = allScrolls[indexPath.row]
        let isEarned = earnedIds.contains(scroll.id)
        cell.configure(scroll: scroll, earned: isEarned)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 84 }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - TrophyCell
final class TrophyCell: UITableViewCell {
    static let reuseId = "TrophyCell_v1"

    private let containerView = UIView()
    private let iconContainer = UIView()
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let rewardLabel = UILabel()
    private let checkmark = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        buildCell()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildCell() {
        containerView.backgroundColor = UIColor(white: 1, alpha: 0.06)
        containerView.layer.cornerRadius = 16
        containerView.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
        containerView.layer.borderWidth = 1
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        iconContainer.layer.cornerRadius = 22
        iconContainer.backgroundColor = UIColor(white: 1, alpha: 0.08)
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(iconContainer)

        iconLabel.font = .systemFont(ofSize: 24)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconLabel)

        titleLabel.font = UIFont(name: GlyphVault.fontBold, size: 15) ?? .boldSystemFont(ofSize: 15)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(titleLabel)

        descLabel.font = UIFont(name: GlyphVault.fontRegular, size: 12) ?? .systemFont(ofSize: 12)
        descLabel.textColor = UIColor(white: 1, alpha: 0.55)
        descLabel.numberOfLines = 2
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(descLabel)

        rewardLabel.font = UIFont(name: GlyphVault.fontBold, size: 12) ?? .boldSystemFont(ofSize: 12)
        rewardLabel.textColor = UIColor(hex: "#FFD700")
        rewardLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(rewardLabel)

        checkmark.font = .systemFont(ofSize: 20)
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(checkmark)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            iconContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            iconContainer.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 44),
            iconContainer.heightAnchor.constraint(equalToConstant: 44),
            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: checkmark.leadingAnchor, constant: -8),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            descLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            rewardLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            rewardLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -6),
            checkmark.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            checkmark.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 28),
        ])
    }

    func configure(scroll: TrophyScroll, earned: Bool) {
        // Map SF Symbol name to emoji fallback
        iconLabel.text = sfSymbolToEmoji(scroll.iconName)
        titleLabel.text = scroll.title
        descLabel.text = scroll.description
        rewardLabel.text = "+\(scroll.tokenReward) 🪙"

        if earned {
            containerView.backgroundColor = UIColor(hex: "#667EEA").withAlphaComponent(0.18)
            containerView.layer.borderColor = UIColor(hex: "#667EEA").withAlphaComponent(0.4).cgColor
            titleLabel.textColor = .white
            checkmark.text = "✅"
            iconContainer.backgroundColor = UIColor(hex: "#667EEA").withAlphaComponent(0.25)
        } else {
            containerView.backgroundColor = UIColor(white: 1, alpha: 0.05)
            containerView.layer.borderColor = UIColor(white: 1, alpha: 0.1).cgColor
            titleLabel.textColor = UIColor(white: 1, alpha: 0.5)
            checkmark.text = "🔒"
            iconContainer.backgroundColor = UIColor(white: 1, alpha: 0.06)
            iconLabel.alpha = 0.45
        }
    }

    private func sfSymbolToEmoji(_ name: String) -> String {
        let map: [String: String] = [
            "arrow.clockwise.circle.fill": "🔄",
            "arrow.2.circlepath": "↩️",
            "arrow.2.circlepath.circle.fill": "🔃",
            "tornado": "🌪️",
            "tornado.circle.fill": "🌀",
            "dollarsign.circle": "💰",
            "dollarsign.circle.fill": "💵",
            "bag.fill": "💼",
            "creditcard": "💳",
            "creditcard.fill": "💳",
            "star.circle": "⭐",
            "star.circle.fill": "🌟",
            "star.fill": "⭐",
            "sparkles": "✨",
            "crown.fill": "👑",
            "checkmark.seal": "✅",
            "checkmark.seal.fill": "🏅",
            "crown": "👑",
            "trophy.fill": "🏆",
            "figure.stand": "🧍",
            "person.3.fill": "👥",
            "hexagon.fill": "⬡",
            "gamecontroller.fill": "🎮",
            "flame.fill": "🔥",
            "bolt.fill": "⚡",
        ]
        return map[name] ?? "🎯"
    }
}
