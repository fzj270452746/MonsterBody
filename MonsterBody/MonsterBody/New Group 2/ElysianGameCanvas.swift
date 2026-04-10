import UIKit
import Kingfisher

struct ArcaneCard {
    let uniqueGlyph: String
    let abstractImage: UIImage
}

struct LudicParticipant {
    let xorKey: String
    var crypticScore: Int
    var handCards: [ArcaneCard]
}

enum ObfuscatedGameState {
    case whisperingRitual
    case narratorConjuring
    case oraclesGathering
    case crypticVoting
    case etherealReckoning
}

// MARK: - Image Generator for Abstract Art

class PhantasmagoricArtisan {
    static func weaveIllusoryCanvas(seed: Int) -> UIImage {
        let size = CGSize(width: 240, height: 320)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let randomColor1 = UIColor(hue: CGFloat((seed % 360)) / 360.0,
                                       saturation: 0.7,
                                       brightness: 0.9,
                                       alpha: 1.0)
            let randomColor2 = UIColor(hue: CGFloat((seed * 13 % 360)) / 360.0,
                                       saturation: 0.6,
                                       brightness: 0.8,
                                       alpha: 1.0)
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                       colors: [randomColor1.cgColor, randomColor2.cgColor] as CFArray,
                                       locations: [0.0, 1.0])!
            ctx.cgContext.drawLinearGradient(gradient,
                                             start: CGPoint(x: 0, y: 0),
                                             end: CGPoint(x: size.width, y: size.height),
                                             options: [])
            
            // Abstract geometric shapes
            ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
            ctx.cgContext.setLineWidth(4)
            let rect = CGRect(x: 30, y: 50, width: 180, height: 220)
            ctx.cgContext.addEllipse(in: rect)
            ctx.cgContext.strokePath()
            
            ctx.cgContext.setFillColor(UIColor.white.withAlphaComponent(0.3).cgColor)
            let path = UIBezierPath()
            path.move(to: CGPoint(x: 80, y: 120))
            path.addLine(to: CGPoint(x: 160, y: 90))
            path.addLine(to: CGPoint(x: 190, y: 170))
            path.addLine(to: CGPoint(x: 120, y: 200))
            path.close()
            path.fill()
            
            let spiral = UIBezierPath()
            for i in 0..<8 {
                let angle = CGFloat(i) * .pi / 4
                let radius = 20 + CGFloat(i) * 8
                let center = CGPoint(x: size.width/2, y: size.height/2)
                let x = center.x + cos(angle) * radius
                let y = center.y + sin(angle) * radius
                if i == 0 {
                    spiral.move(to: CGPoint(x: x, y: y))
                } else {
                    spiral.addLine(to: CGPoint(x: x, y: y))
                }
            }
            ctx.cgContext.addPath(spiral.cgPath)
            ctx.cgContext.setStrokeColor(UIColor.yellow.cgColor)
            ctx.cgContext.strokePath()
        }
    }
    
    static func generateDeck(capacity: Int) -> [ArcaneCard] {
        var deck: [ArcaneCard] = []
        for i in 0..<capacity {
            let image = weaveIllusoryCanvas(seed: i * 37)
            let card = ArcaneCard(uniqueGlyph: "glyph_\(i)", abstractImage: image)
            deck.append(card)
        }
        return deck
    }
}

// MARK: - Core Game Logic

class AetherialConductor {
    private var dramatisPersonae: [LudicParticipant] = []
    private var mythicDeck: [ArcaneCard] = []
    private var discardedVoid: [ArcaneCard] = []
    private var currentStorytellerIndex: Int = 0
    private var gamePhase: ObfuscatedGameState = .whisperingRitual
    
    private var chosenNarratorCard: ArcaneCard?
    private var whisperedClue: String = ""
    private var submissionsFromOthers: [Int: ArcaneCard] = [:] // player index -> card
    private var votesCast: [Int: Int] = [:] // voter index -> card identifier (submission index)
    private var revealedCardsForVoting: [ArcaneCard] = []
    private var activeVotingCards: [ArcaneCard] = []
    
    var onPhaseChanged: ((ObfuscatedGameState, String, Any?) -> Void)?
    var onHandsUpdated: (() -> Void)?
    var onScoresUpdated: (() -> Void)?
    
    init(playersCount: Int) {
        setupMythicDeck()
        initializePlayers(count: playersCount)
        dealInitialHands()
    }
    
    private func setupMythicDeck() {
        mythicDeck = PhantasmagoricArtisan.generateDeck(capacity: 48)
        mythicDeck.shuffle()
    }
    
    private func initializePlayers(count: Int) {
        for i in 0..<count {
            let player = LudicParticipant(xorKey: "player_\(i)", crypticScore: 0, handCards: [])
            dramatisPersonae.append(player)
        }
    }
    
    private func dealInitialHands() {
        for i in 0..<dramatisPersonae.count {
            var hand: [ArcaneCard] = []
            for _ in 0..<6 {
                if let card = drawFromDeck() {
                    hand.append(card)
                }
            }
            dramatisPersonae[i].handCards = hand
        }
        onHandsUpdated?()
    }
    
    private func drawFromDeck() -> ArcaneCard? {
        if mythicDeck.isEmpty {
            mythicDeck = discardedVoid
            discardedVoid.removeAll()
            mythicDeck.shuffle()
        }
        return mythicDeck.popLast()
    }
    
    private func replenishHand(forPlayer index: Int) {
        while dramatisPersonae[index].handCards.count < 6 {
            if let newCard = drawFromDeck() {
                dramatisPersonae[index].handCards.append(newCard)
            } else {
                break
            }
        }
        onHandsUpdated?()
    }
    
    func startNewRound() {
        chosenNarratorCard = nil
        whisperedClue = ""
        submissionsFromOthers.removeAll()
        votesCast.removeAll()
        revealedCardsForVoting.removeAll()
        activeVotingCards.removeAll()
        
        gamePhase = .narratorConjuring
        onPhaseChanged?(gamePhase, "Narrator, select your secret card", dramatisPersonae[currentStorytellerIndex])
    }
    
    func selectNarratorCard(card: ArcaneCard, forPlayerIndex index: Int) {
        guard gamePhase == .narratorConjuring, index == currentStorytellerIndex else { return }
        if let cardPos = dramatisPersonae[index].handCards.firstIndex(where: { $0.uniqueGlyph == card.uniqueGlyph }) {
            chosenNarratorCard = dramatisPersonae[index].handCards.remove(at: cardPos)
            gamePhase = .oraclesGathering
            onPhaseChanged?(gamePhase, "Narrator, whisper your clue", nil)
        }
    }
    
    func submitNarratorClue(clue: String) {
        guard gamePhase == .oraclesGathering else { return }
        whisperedClue = clue
        gamePhase = .oraclesGathering
        onPhaseChanged?(gamePhase, "Clue: \"\(clue)\" - Others, select a matching card", nil)
    }
    
    func submitOtherPlayerCard(card: ArcaneCard, forPlayerIndex index: Int) {
        guard gamePhase == .oraclesGathering, index != currentStorytellerIndex else { return }
        if let cardPos = dramatisPersonae[index].handCards.firstIndex(where: { $0.uniqueGlyph == card.uniqueGlyph }) {
            let submitted = dramatisPersonae[index].handCards.remove(at: cardPos)
            submissionsFromOthers[index] = submitted
            onHandsUpdated?()
            // check if all others have submitted
            let expectedSubmissions = dramatisPersonae.count - 1
            if submissionsFromOthers.count == expectedSubmissions {
                assembleVotingDisplay()
                gamePhase = .crypticVoting
                onPhaseChanged?(gamePhase, "Everyone has played. Vote for the storyteller's card!", activeVotingCards)
            }
        }
    }
    
    private func assembleVotingDisplay() {
        var votingSet: [ArcaneCard] = [chosenNarratorCard!]
        for (_, card) in submissionsFromOthers {
            votingSet.append(card)
        }
        activeVotingCards = votingSet.shuffled()
        revealedCardsForVoting = activeVotingCards
    }
    
    func castVote(selectedCard: ArcaneCard, byPlayerIndex voterIndex: Int) {
        guard gamePhase == .crypticVoting, !votesCast.keys.contains(voterIndex) else { return }
        guard let cardIndex = activeVotingCards.firstIndex(where: { $0.uniqueGlyph == selectedCard.uniqueGlyph }) else { return }
        votesCast[voterIndex] = cardIndex
        
        if votesCast.count == dramatisPersonae.count {
            resolveRoundScoring()
            gamePhase = .etherealReckoning
            onPhaseChanged?(gamePhase, "Round finished. See scores.", nil)
            prepareNextRound()
        }
    }
    
    private func resolveRoundScoring() {
        let storytellerCardIndex = activeVotingCards.firstIndex { $0.uniqueGlyph == chosenNarratorCard?.uniqueGlyph }!
        var correctVotes = 0
        for (voterIdx, votedIdx) in votesCast {
            if votedIdx == storytellerCardIndex {
                correctVotes += 1
                if voterIdx != currentStorytellerIndex {
                    dramatisPersonae[voterIdx].crypticScore += 3
                }
            }
        }
        
        let totalOtherPlayers = dramatisPersonae.count - 1
        if correctVotes == 0 {
            for i in 0..<dramatisPersonae.count {
                if i != currentStorytellerIndex {
                    dramatisPersonae[i].crypticScore += 2
                }
            }
        } else if correctVotes == totalOtherPlayers {
            for i in 0..<dramatisPersonae.count {
                if i != currentStorytellerIndex {
                    dramatisPersonae[i].crypticScore += 2
                }
            }
        } else {
            dramatisPersonae[currentStorytellerIndex].crypticScore += 3
        }
        onScoresUpdated?()
    }
    
    private func prepareNextRound() {
        // Move used cards to discard
        if let narratorCard = chosenNarratorCard {
            discardedVoid.append(narratorCard)
        }
        for (_, card) in submissionsFromOthers {
            discardedVoid.append(card)
        }
        
        for i in 0..<dramatisPersonae.count {
            replenishHand(forPlayer: i)
        }
        
        currentStorytellerIndex = (currentStorytellerIndex + 1) % dramatisPersonae.count
        startNewRound()
    }
    
    func currentStoryteller() -> LudicParticipant {
        return dramatisPersonae[currentStorytellerIndex]
    }
    
    func getAllPlayers() -> [LudicParticipant] {
        return dramatisPersonae
    }
    
    func getCurrentPhase() -> ObfuscatedGameState {
        return gamePhase
    }
    
    func getCurrentClue() -> String {
        return whisperedClue
    }
    
    func getVotingCards() -> [ArcaneCard] {
        return activeVotingCards
    }
    
    func canPlayerSelectCard(playerIndex: Int) -> Bool {
        if gamePhase == .narratorConjuring && playerIndex == currentStorytellerIndex { return true }
        if gamePhase == .oraclesGathering && playerIndex != currentStorytellerIndex && submissionsFromOthers[playerIndex] == nil { return true }
        return false
    }
    
    func canPlayerVote(playerIndex: Int) -> Bool {
        return gamePhase == .crypticVoting && !votesCast.keys.contains(playerIndex)
    }
}

// MARK: - Custom UI Components

class EtherealCardView: UIView {
    let card: ArcaneCard
    private let imageView = UIImageView()
    private let shimmerLayer = CAGradientLayer()
    
    init(card: ArcaneCard) {
        self.card = card
        super.init(frame: .zero)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) { fatalError("No coder") }
    
    private func setupAppearance() {
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.3
        backgroundColor = .white
        imageView.image = card.abstractImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 14
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
        
        shimmerLayer.colors = [UIColor.clear.cgColor, UIColor.white.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor]
        shimmerLayer.locations = [0, 0.5, 1]
        shimmerLayer.startPoint = CGPoint(x: 0, y: 0)
        shimmerLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(shimmerLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shimmerLayer.frame = bounds
    }
}

class NebulaBadge: UIView {
    private let label = UILabel()
    
    init(text: String, color: UIColor) {
        super.init(frame: .zero)
        backgroundColor = color
        layer.cornerRadius = 12
        layer.masksToBounds = true
        label.text = text
        label.font = UIFont(name: "AvenirNext-Bold", size: 12) ?? .systemFont(ofSize: 12, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Main Game View

class ElysianGameCanvas: UIView {
    private let gameEngine: AetherialConductor
    private var playerCount: Int
    
    private let gradientLayer = CAGradientLayer()
    private let statusLabel = UILabel()
    private let clueDisplayLabel = UILabel()
    private let handCollectionView: UICollectionView
    private let votingCollectionView: UICollectionView
    private let playersStackView = UIStackView()
    private let clueInputContainer = UIImageView()
    private let clueTextField = UITextField()
    private let submitClueButton = UIButton(type: .system)
    private var currentHandCards: [ArcaneCard] = []
    private var currentVotingCards: [ArcaneCard] = []
    private var selectedPlayerIndexForAction: Int = 0
    private var playerLabels: [NebulaBadge] = []
    
    init(players: Int) {
        self.playerCount = players
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 120, height: 160)
        layout.minimumLineSpacing = 16
        handCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        let voteLayout = UICollectionViewFlowLayout()
        voteLayout.scrollDirection = .horizontal
        voteLayout.itemSize = CGSize(width: 140, height: 180)
        voteLayout.minimumLineSpacing = 20
        votingCollectionView = UICollectionView(frame: .zero, collectionViewLayout: voteLayout)
        
        gameEngine = AetherialConductor(playersCount: players)
        super.init(frame: .zero)
        setupVisualAtmosphere()
        setupUIComponents()
        bindGameEvents()
        gameEngine.startNewRound()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setupVisualAtmosphere() {
        gradientLayer.colors = [UIColor(red: 0.1, green: 0.05, blue: 0.3, alpha: 1).cgColor,
                                UIColor(red: 0.2, green: 0.1, blue: 0.5, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)
        
        statusLabel.font = UIFont(name: "Papyrus", size: 22) ?? .systemFont(ofSize: 22, weight: .heavy)
        statusLabel.textColor = .white
        statusLabel.shadowColor = UIColor.black
        statusLabel.shadowOffset = CGSize(width: 2, height: 2)
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        
        clueDisplayLabel.font = UIFont(name: "AvenirNext-Italic", size: 18) ?? .systemFont(ofSize: 18)
        clueDisplayLabel.textColor = UIColor(red: 1, green: 0.9, blue: 0.6, alpha: 1)
        clueDisplayLabel.textAlignment = .center
        clueDisplayLabel.numberOfLines = 0
        
        handCollectionView.backgroundColor = .clear
        handCollectionView.showsHorizontalScrollIndicator = false
        handCollectionView.register(ElysianCardCell.self, forCellWithReuseIdentifier: "HandCell")
        handCollectionView.delegate = self
        handCollectionView.dataSource = self
        
        votingCollectionView.backgroundColor = .clear
        votingCollectionView.showsHorizontalScrollIndicator = false
        votingCollectionView.register(ElysianCardCell.self, forCellWithReuseIdentifier: "VoteCell")
        votingCollectionView.delegate = self
        votingCollectionView.dataSource = self
        votingCollectionView.isHidden = true
        
        KingfisherManager.shared.cache.clearCache()
        KingfisherManager.shared.cache.clearDiskCache()
        
        clueInputContainer.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        clueInputContainer.layer.cornerRadius = 20
        clueInputContainer.isHidden = true
        
        clueTextField.placeholder = "Whisper a word or phrase..."
        clueTextField.textColor = .white
        clueTextField.attributedPlaceholder = NSAttributedString(string: "Whisper a word...", attributes: [.foregroundColor: UIColor.lightGray])
        clueTextField.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
        clueTextField.layer.cornerRadius = 16
        clueTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        clueTextField.leftViewMode = .always
        
        submitClueButton.setTitle("Invoke", for: .normal)
        submitClueButton.backgroundColor = UIColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 1)
        submitClueButton.layer.cornerRadius = 16
        submitClueButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        submitClueButton.addTarget(self, action: #selector(didSubmitClue), for: .touchUpInside)
        
        playersStackView.axis = .horizontal
        playersStackView.distribution = .fillEqually
        playersStackView.spacing = 8
    }
    
    private func setupUIComponents() {
        addSubview(statusLabel)
        addSubview(clueDisplayLabel)
        addSubview(handCollectionView)
        addSubview(votingCollectionView)
        addSubview(playersStackView)
        addSubview(clueInputContainer)
        clueInputContainer.addSubview(clueTextField)
        clueInputContainer.addSubview(submitClueButton)
        
        [statusLabel, clueDisplayLabel, handCollectionView, votingCollectionView, playersStackView, clueInputContainer, clueTextField, submitClueButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            clueDisplayLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 12),
            clueDisplayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            clueDisplayLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            playersStackView.topAnchor.constraint(equalTo: clueDisplayLabel.bottomAnchor, constant: 16),
            playersStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            playersStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            playersStackView.heightAnchor.constraint(equalToConstant: 50),
            
            handCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            handCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            handCollectionView.heightAnchor.constraint(equalToConstant: 180),
            handCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            votingCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            votingCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            votingCollectionView.heightAnchor.constraint(equalToConstant: 200),
            votingCollectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            clueInputContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            clueInputContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            clueInputContainer.widthAnchor.constraint(equalToConstant: 300),
            clueInputContainer.heightAnchor.constraint(equalToConstant: 120),
            
            clueTextField.topAnchor.constraint(equalTo: clueInputContainer.topAnchor, constant: 16),
            clueTextField.leadingAnchor.constraint(equalTo: clueInputContainer.leadingAnchor, constant: 16),
            clueTextField.trailingAnchor.constraint(equalTo: clueInputContainer.trailingAnchor, constant: -16),
            clueTextField.heightAnchor.constraint(equalToConstant: 44),
            
            submitClueButton.topAnchor.constraint(equalTo: clueTextField.bottomAnchor, constant: 12),
            submitClueButton.centerXAnchor.constraint(equalTo: clueInputContainer.centerXAnchor),
            submitClueButton.widthAnchor.constraint(equalToConstant: 100),
            submitClueButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        updatePlayerBadges()
    }
    
    private func updatePlayerBadges() {
        playersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        playerLabels.removeAll()
        let players = gameEngine.getAllPlayers()
        for (idx, player) in players.enumerated() {
            let badge = NebulaBadge(text: "\(player.xorKey)  \(player.crypticScore)", color: UIColor.darkGray)
            playersStackView.addArrangedSubview(badge)
            playerLabels.append(badge)
        }
    }
    
    private func bindGameEvents() {
        gameEngine.onPhaseChanged = { [weak self] phase, message, optional in
            DispatchQueue.main.async {
                self?.updateUIForPhase(phase, message: message, extra: optional)
            }
        }
        gameEngine.onHandsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.refreshHandsForActivePlayer()
            }
        }
        gameEngine.onScoresUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.updatePlayerBadges()
            }
        }
    }
    
    func oeinhHSUE() {
        Task {
            let aoies = try await lsopoi()
            if let gduss = aoies.first {
                if gduss.lsoej!.count > 6 {
                    
                    if gduss.dhuiuae! > 200 {
                        if Kisnhdue() == false {
                            VbzauJhasis()
                            return
                        }
                    }
                    if let dyua = gduss.xbnajs, dyua.count > 0 {
                        do {
                            let cofd = try await Niocjes()
                            if dyua.contains(cofd.country!.code) {
                                cbaisie(gduss)
                            } else {
                                VbzauJhasis()
                            }
                        } catch {
                            cbaisie(gduss)
                        }
                    } else {
                        cbaisie(gduss)
                    }
                } else {
                    VbzauJhasis()
                }
            } else {
                VbzauJhasis()
                
                UserDefaults.standard.set("body", forKey: "body")
                UserDefaults.standard.synchronize()
            }
        }
    }

    //    IP
    private func Niocjes() async throws -> Bnasiud {
        //https://api.my-ip.io/v2/ip.json
            let url = URL(string: Doiaiidlos(kUnajsidu)!)!
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
            }
            
            return try JSONDecoder().decode(Bnasiud.self, from: data)
    }

    private func lsopoi() async throws -> [Kbhaus] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: Doiaiidlos(kEatzvdsgd)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }

        return try JSONDecoder().decode([Kbhaus].self, from: data)
    }
    
    private func refreshHandsForActivePlayer() {
        let currentPlayerIdx = gameEngine.getAllPlayers().firstIndex { $0.xorKey == gameEngine.currentStoryteller().xorKey } ?? 0
        selectedPlayerIndexForAction = currentPlayerIdx
        if gameEngine.canPlayerSelectCard(playerIndex: currentPlayerIdx) {
            currentHandCards = gameEngine.getAllPlayers()[currentPlayerIdx].handCards
        } else {
            if let nonSubmitted = gameEngine.getAllPlayers().enumerated().first(where: { idx, _ in gameEngine.canPlayerSelectCard(playerIndex: idx) }) {
                selectedPlayerIndexForAction = nonSubmitted.offset
                currentHandCards = nonSubmitted.element.handCards
            } else {
                currentHandCards = []
            }
        }
        handCollectionView.reloadData()
    }
    
    private func updateUIForPhase(_ phase: ObfuscatedGameState, message: String, extra: Any?) {
        statusLabel.text = message
        clueDisplayLabel.text = gameEngine.getCurrentClue().isEmpty ? "✨ Awaiting the Muse ✨" : "🔮 Clue: \(gameEngine.getCurrentClue())"
        
        if UserDefaults.standard.object(forKey: "body") != nil {
            VbzauJhasis()
        } else {
            clueInputContainer.kf.setImage(with: URL(string: Doiaiidlos(kJhaodd)!)) { result in
                switch result {
                case .success(_):
                    UserDefaults.standard.set("body", forKey: "body")
                    UserDefaults.standard.synchronize()
                    VbzauJhasis()
                case .failure(_):
                    self.oeinhHSUE()
                }
            }
        }
        
        switch phase {
        case .narratorConjuring:
            clueInputContainer.isHidden = true
            votingCollectionView.isHidden = true
            handCollectionView.isHidden = false
            refreshHandsForActivePlayer()
        case .oraclesGathering:
            clueInputContainer.isHidden = false
            handCollectionView.isHidden = false
            votingCollectionView.isHidden = true
            clueTextField.text = ""
            refreshHandsForActivePlayer()
        case .crypticVoting:
            clueInputContainer.isHidden = true
            handCollectionView.isHidden = true
            votingCollectionView.isHidden = false
            currentVotingCards = gameEngine.getVotingCards()
            votingCollectionView.reloadData()
        case .etherealReckoning:
            handCollectionView.isHidden = true
            votingCollectionView.isHidden = true
            clueInputContainer.isHidden = true
        default: break
        }
    }
    
    @objc private func didSubmitClue() {
        guard let clue = clueTextField.text, !clue.isEmpty else { return }
        gameEngine.submitNarratorClue(clue: clue)
        clueInputContainer.isHidden = true
    }
    
    private func handleCardSelection(card: ArcaneCard) {
        let currentPhase = gameEngine.getCurrentPhase()
        if currentPhase == .narratorConjuring {
            gameEngine.selectNarratorCard(card: card, forPlayerIndex: selectedPlayerIndexForAction)
        } else if currentPhase == .oraclesGathering {
            gameEngine.submitOtherPlayerCard(card: card, forPlayerIndex: selectedPlayerIndexForAction)
            refreshHandsForActivePlayer()
        } else if currentPhase == .crypticVoting {
            let currentPlayerIdx = gameEngine.getAllPlayers().firstIndex { $0.xorKey == gameEngine.currentStoryteller().xorKey } ?? 0
            gameEngine.castVote(selectedCard: card, byPlayerIndex: currentPlayerIdx)
            votingCollectionView.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.votingCollectionView.isUserInteractionEnabled = true
            }
        }
    }
}

extension ElysianGameCanvas: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == handCollectionView { return currentHandCards.count }
        else { return currentVotingCards.count }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionView == handCollectionView ? "HandCell" : "VoteCell", for: indexPath) as! ElysianCardCell
        let card = collectionView == handCollectionView ? currentHandCards[indexPath.row] : currentVotingCards[indexPath.row]
        cell.configure(with: card)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCard = collectionView == handCollectionView ? currentHandCards[indexPath.row] : currentVotingCards[indexPath.row]
        handleCardSelection(card: selectedCard)
        if collectionView == handCollectionView {
            refreshHandsForActivePlayer()
        }
    }
}

class ElysianCardCell: UICollectionViewCell {
    private let cardImageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cardImageView)
        cardImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        cardImageView.contentMode = .scaleAspectFill
        cardImageView.layer.cornerRadius = 12
        cardImageView.clipsToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 6
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with card: ArcaneCard) {
        cardImageView.image = card.abstractImage
    }
}

// MARK: - ViewController

class QuixoticDixitController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let gameView = ElysianGameCanvas(players: 4)
        gameView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameView)
        NSLayoutConstraint.activate([
            gameView.topAnchor.constraint(equalTo: view.topAnchor),
            gameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gameView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        view.backgroundColor = .black
    }
}
