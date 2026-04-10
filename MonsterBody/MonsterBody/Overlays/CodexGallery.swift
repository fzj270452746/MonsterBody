import UIKit

// MARK: - CodexGallery: Monster Collection UIViewController
final class CodexGallery: UIViewController {
    private var collectionView: UICollectionView!
    private var allBeasts = BeastRoster.allBeasts

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildBackground()
        buildNavBar()
        buildCollectionView()
        buildStatsBar()
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
        titleLabel.text = "My Collection"
        titleLabel.font = UIFont(name: GlyphVault.fontHeavy, size: 22) ?? .boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)

        let closeBtn = buildGradientButton(title: "✕", width: 44, height: 44)
        closeBtn.addTarget(self, action: #selector(dismissGallery), for: .touchUpInside)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeBtn)

        // Coin HUD
        let trove = TroveKeeper.shared
        let coinLabel = buildCoinLabel(balance: trove.vaultBalance)
        view.addSubview(coinLabel)

        let safeTop = view.safeAreaInsets.top + 14
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            closeBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeBtn.widthAnchor.constraint(equalToConstant: 44),
            closeBtn.heightAnchor.constraint(equalToConstant: 44),
            coinLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            coinLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
        ])
    }

    private func buildCoinLabel(balance: Int) -> UILabel {
        let lbl = UILabel()
        lbl.text = "🪙 \(balance)"
        lbl.font = UIFont(name: GlyphVault.fontBold, size: 14) ?? .boldSystemFont(ofSize: 14)
        lbl.textColor = UIColor(hex: "#FFD700")
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }

    // MARK: - Stats Bar
    private func buildStatsBar() {
        let trove = TroveKeeper.shared
        let total = BeastRoster.allBeasts.count
        let unlocked = trove.enshrineCount
        let pct = Int(Double(unlocked) / Double(total) * 100)

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor(white: 1, alpha: 0.07)
        container.layer.cornerRadius = 14
        container.layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
        container.layer.borderWidth = 1
        view.addSubview(container)

        let statsLabel = UILabel()
        statsLabel.text = "\(unlocked)/\(total) Monsters (\(pct)%)"
        statsLabel.font = UIFont(name: GlyphVault.fontMedium, size: 14) ?? .systemFont(ofSize: 14)
        statsLabel.textColor = UIColor(white: 1, alpha: 0.8)
        statsLabel.textAlignment = .center
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(statsLabel)

        // Progress bar
        let progressBg = UIView()
        progressBg.backgroundColor = UIColor(white: 1, alpha: 0.12)
        progressBg.layer.cornerRadius = 4
        progressBg.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(progressBg)

        let progressFill = UIView()
        progressFill.layer.cornerRadius = 4
        let grad = CAGradientLayer()
        grad.colors = [UIColor(hex: "#667EEA").cgColor, UIColor(hex: "#4ECDC4").cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0.5)
        grad.endPoint = CGPoint(x: 1, y: 0.5)
        progressFill.layer.addSublayer(grad)
        progressFill.translatesAutoresizingMaskIntoConstraints = false
        progressBg.addSubview(progressFill)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 58),
            container.heightAnchor.constraint(equalToConstant: 52),
            statsLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: -8),
            statsLabel.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            progressBg.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            progressBg.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            progressBg.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
            progressBg.heightAnchor.constraint(equalToConstant: 8),
            progressFill.leadingAnchor.constraint(equalTo: progressBg.leadingAnchor),
            progressFill.topAnchor.constraint(equalTo: progressBg.topAnchor),
            progressFill.bottomAnchor.constraint(equalTo: progressBg.bottomAnchor),
        ])

        // Animate progress fill after layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let barW = self.view.bounds.width - 64
            grad.frame = CGRect(x: 0, y: 0, width: barW * CGFloat(pct) / 100, height: 8)
            progressFill.widthAnchor.constraint(equalTo: progressBg.widthAnchor, multiplier: CGFloat(pct) / 100).isActive = true
        }
    }

    // MARK: - Collection View
    private func buildCollectionView() {
        let cols: CGFloat = 3
        let gap: CGFloat = 12
        let inset: CGFloat = 16
        let itemW = (view.bounds.width - inset * 2 - gap * (cols - 1)) / cols
        let itemH = itemW * 1.4

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemW, height: itemH)
        layout.minimumInteritemSpacing = gap
        layout.minimumLineSpacing = gap
        layout.sectionInset = UIEdgeInsets(top: 16, left: inset, bottom: 20, right: inset)
        layout.headerReferenceSize = CGSize(width: view.bounds.width, height: 44)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(BeastCell.self, forCellWithReuseIdentifier: BeastCell.reuseId)
        collectionView.register(SectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: SectionHeaderView.reuseId)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 118),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    @objc private func dismissGallery() {
        dismiss(animated: true)
    }

    private func buildGradientButton(title: String, width: CGFloat, height: CGFloat) -> UIButton {
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(white: 1, alpha: 0.1)
        btn.layer.cornerRadius = min(width, height) / 2
        btn.layer.borderColor = UIColor(white: 1, alpha: 0.2).cgColor
        btn.layer.borderWidth = 1
        return btn
    }

    // Section data
    private var sections: [(title: String, beasts: [BeastBlueprint])] {
        [
            ("✦✦ Treasure  (4)", BeastRoster.prizableBeasts),
            ("✦ Rare  (5)",      BeastRoster.scarceBeasts),
            ("Normal  (7)",      BeastRoster.ordinaryBeasts),
        ]
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension CodexGallery: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int { sections.count }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].beasts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BeastCell.reuseId, for: indexPath) as! BeastCell
        let beast = sections[indexPath.section].beasts[indexPath.item]
        let isUnlocked = TroveKeeper.shared.isBeastEnshrined(beast)
        cell.configure(beast: beast, unlocked: isUnlocked)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseId, for: indexPath) as! SectionHeaderView
        header.configure(title: sections[indexPath.section].title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let beast = sections[indexPath.section].beasts[indexPath.item]
        let isUnlocked = TroveKeeper.shared.isBeastEnshrined(beast)
        showBeastDetail(beast: beast, unlocked: isUnlocked)
    }

    private func showBeastDetail(beast: BeastBlueprint, unlocked: Bool) {
        let vc = BeastDetailSheet(beast: beast, unlocked: unlocked)
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        present(vc, animated: true)
    }
}

// MARK: - BeastCell
final class BeastCell: UICollectionViewCell {
    static let reuseId = "BeastCell_v1"
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let rarityBadge = UILabel()
    private let lockOverlay = UIView()
    private let lockIcon = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupCell() {
        contentView.layer.cornerRadius = 16
        contentView.layer.borderColor = UIColor(white: 1, alpha: 0.12).cgColor
        contentView.layer.borderWidth = 1
        contentView.backgroundColor = UIColor(white: 1, alpha: 0.06)
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        rarityBadge.font = UIFont(name: GlyphVault.fontBold, size: 9) ?? .boldSystemFont(ofSize: 9)
        rarityBadge.textAlignment = .center
        rarityBadge.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(rarityBadge)

        nameLabel.font = UIFont(name: GlyphVault.fontMedium, size: 10) ?? .systemFont(ofSize: 10)
        nameLabel.textColor = UIColor(white: 1, alpha: 0.8)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nameLabel)

        lockOverlay.backgroundColor = UIColor(white: 0, alpha: 0.6)
        lockOverlay.isHidden = true
        lockOverlay.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lockOverlay)

        lockIcon.text = "🔒"
        lockIcon.font = .systemFont(ofSize: 28)
        lockIcon.textAlignment = .center
        lockIcon.translatesAutoresizingMaskIntoConstraints = false
        lockOverlay.addSubview(lockIcon)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.78),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            rarityBadge.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            rarityBadge.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            rarityBadge.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            rarityBadge.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            nameLabel.topAnchor.constraint(equalTo: rarityBadge.bottomAnchor, constant: 2),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            lockOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            lockOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            lockOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            lockOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            lockIcon.centerXAnchor.constraint(equalTo: lockOverlay.centerXAnchor),
            lockIcon.centerYAnchor.constraint(equalTo: lockOverlay.centerYAnchor),
        ])
    }

    func configure(beast: BeastBlueprint, unlocked: Bool) {
        nameLabel.text = unlocked ? beast.displayName : "???"

        if unlocked, let img = UIImage(named: beast.assetName) {
            imageView.image = img
            imageView.alpha = 1
        } else {
            imageView.image = UIImage(named: beast.assetName)
            imageView.alpha = 0.1
        }

        rarityBadge.text = beast.rarity.badgeText
        let rc = beast.rarity.glowColor
        rarityBadge.textColor = rc

        lockOverlay.isHidden = unlocked
        contentView.layer.borderColor = unlocked ?
            beast.rarity.glowColor.withAlphaComponent(0.45).cgColor :
            UIColor(white: 1, alpha: 0.08).cgColor
    }
}

// MARK: - SectionHeaderView
final class SectionHeaderView: UICollectionReusableView {
    static let reuseId = "SectionHeader_v1"
    private let titleLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = UIFont(name: GlyphVault.fontBold, size: 15) ?? .boldSystemFont(ofSize: 15)
        titleLabel.textColor = UIColor(white: 1, alpha: 0.85)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(title: String) { titleLabel.text = title }
}

// MARK: - BeastDetailSheet: full-screen monster detail popup
final class BeastDetailSheet: UIViewController {
    private let beast: BeastBlueprint
    private let unlocked: Bool

    init(beast: BeastBlueprint, unlocked: Bool) {
        self.beast = beast
        self.unlocked = unlocked
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0, alpha: 0.65)
        buildDetailCard()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    private func buildDetailCard() {
        let card = UIView()
        card.backgroundColor = UIColor(hex: "#1E1E3A")
        card.layer.cornerRadius = 28
        card.layer.borderColor = beast.rarity.glowColor.withAlphaComponent(0.6).cgColor
        card.layer.borderWidth = 2
        card.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(card)

        let cardW = min(view.bounds.width - 48, 320)

        // Monster image
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.image = UIImage(named: beast.assetName)
        imgView.alpha = unlocked ? 1 : 0.15
        imgView.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(imgView)

        // Rarity label
        let rarityLbl = UILabel()
        rarityLbl.text = beast.rarity.badgeText
        rarityLbl.font = UIFont(name: GlyphVault.fontBold, size: 14) ?? .boldSystemFont(ofSize: 14)
        rarityLbl.textColor = beast.rarity.glowColor
        rarityLbl.textAlignment = .center
        rarityLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(rarityLbl)

        // Name label
        let nameLbl = UILabel()
        nameLbl.text = unlocked ? beast.displayName : "??? Unknown"
        nameLbl.font = UIFont(name: GlyphVault.fontHeavy, size: 22) ?? .boldSystemFont(ofSize: 22)
        nameLbl.textColor = .white
        nameLbl.textAlignment = .center
        nameLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nameLbl)

        // Formula (if unlocked)
        let formulaText = unlocked ? buildFormulaText() : "Unlock to reveal the recipe..."
        let formulaLbl = UILabel()
        formulaLbl.text = formulaText
        formulaLbl.font = UIFont(name: GlyphVault.fontRegular, size: 12) ?? .systemFont(ofSize: 12)
        formulaLbl.textColor = UIColor(white: 1, alpha: 0.6)
        formulaLbl.textAlignment = .center
        formulaLbl.numberOfLines = 0
        formulaLbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(formulaLbl)

        // Lock icon overlay
        if !unlocked {
            let lockLbl = UILabel()
            lockLbl.text = "🔒"
            lockLbl.font = .systemFont(ofSize: 52)
            lockLbl.textAlignment = .center
            lockLbl.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(lockLbl)
            NSLayoutConstraint.activate([
                lockLbl.centerXAnchor.constraint(equalTo: imgView.centerXAnchor),
                lockLbl.centerYAnchor.constraint(equalTo: imgView.centerYAnchor),
            ])
        }

        // Close button
        let closeBtn = UIButton(type: .system)
        closeBtn.setTitle("Close", for: .normal)
        closeBtn.titleLabel?.font = UIFont(name: GlyphVault.fontBold, size: 17) ?? .boldSystemFont(ofSize: 17)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.backgroundColor = UIColor(hex: "#667EEA")
        closeBtn.layer.cornerRadius = 22
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        card.addSubview(closeBtn)

        let cardH: CGFloat = 460
        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            card.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            card.widthAnchor.constraint(equalToConstant: cardW),
            card.heightAnchor.constraint(equalToConstant: cardH),
            imgView.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            imgView.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            imgView.widthAnchor.constraint(equalToConstant: 160),
            imgView.heightAnchor.constraint(equalToConstant: 160),
            rarityLbl.topAnchor.constraint(equalTo: imgView.bottomAnchor, constant: 14),
            rarityLbl.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            nameLbl.topAnchor.constraint(equalTo: rarityLbl.bottomAnchor, constant: 8),
            nameLbl.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            formulaLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 12),
            formulaLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            formulaLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            closeBtn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            closeBtn.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            closeBtn.widthAnchor.constraint(equalToConstant: cardW - 60),
            closeBtn.heightAnchor.constraint(equalToConstant: 50),
        ])

        // Tap outside to dismiss
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        view.addGestureRecognizer(tap)
        card.isUserInteractionEnabled = true
        card.addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))  // absorb taps
    }

    private func buildFormulaText() -> String {
        let parts = BodyPartCategory.allCases
        return parts.compactMap { part -> String? in
            guard let idx = beast.partFormula[part] else { return nil }
            return "\(part.displayName): Style \(idx)"
        }.joined(separator: "  •  ")
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
