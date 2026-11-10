import SpriteKit
import Combine
import CoreMotion

// MARK: - Campaign Reentry Constants
struct CampaignReentryState {
    static let initialTilt: CGFloat = 0.12          // ~6.9° left tilt (radians)
    static let initialHorizontalSpeed: CGFloat = 15.0  // rightward drift (pts/s)
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Properties (accessible to extensions)
    var gameState: GameState
    var campaignState: CampaignState
    var rocket: SKNode!
    var platforms: [SKShapeNode] = []
    var ground: SKShapeNode!
    var terrain: SKShapeNode!
    var hasStarted = false
    var lastUpdateTime: TimeInterval = 0

    // Ship visuals
    var shipSkin: ShipSkin = .stainless
    var enginePlume: SKEmitterNode?
    var engineGlow: SKSpriteNode?
    var isEngineLit = false

    // Camera + flight guidance
    var cameraNode: SKCameraNode?
    var guidanceLine: SKSpriteNode?
    var guidanceLabel: SKLabelNode?
    var dustEmitter: SKEmitterNode?
    var frameCounter = 0

    // Terrain surface samples (for altitude, dust and guidance)
    var terrainHeights: [CGFloat] = []
    let terrainSegmentWidth: CGFloat = 20

    // Sound nodes
    var thrustSound: SKAudioNode?
    var isThrustSoundPlaying = false
    var wasRotatingLeft = false
    var wasRotatingRight = false

    // Accelerometer
    private let motionManager = CMMotionManager()
    private var accelerometerTilt: CGFloat = 0

    // Velocity tracking
    var maxDescentSpeed: CGFloat = 0
    var recentVelocities: [CGFloat] = []
    let velocityHistorySize = 30

    // Elapsed time tracking (for timed daily challenges)
    private var gameStartTime: TimeInterval = 0

    // Pre-contact tracking (for end-of-run snapshot — always reflects last update frame)
    private var lastTrackedVerticalSpeed: CGFloat = 0
    private var lastTrackedHorizontalSpeed: CGFloat = 0
    private var lastTrackedTilt: CGFloat = 0  // signed

    // Campaign: wind state
    private var windForce: CGFloat = 0
    private var windTime: TimeInterval = 0

    // Campaign: Jupiter gust state
    private var gustActive = false
    private var gustTimer: TimeInterval = 0
    private var gustDirection: CGFloat = 1
    private var gustCalmDuration: TimeInterval = 3.0
    private var gustActiveDuration: TimeInterval = 2.0

    // Campaign: cryogeyser state (Europa)
    var geyserPositions: [CGFloat] = []
    var geyserActive: [Bool] = []
    var geyserTimers: [TimeInterval] = []
    var geyserActiveDurations: [TimeInterval] = []
    var geyserCalmDurations: [TimeInterval] = []

    // Campaign: moving platforms (per-platform state)
    private var platformDirections: [CGFloat] = [1, 1, 1]
    private var platformOriginalPositions: [CGPoint] = []

    // Physics categories
    let rocketCategory: UInt32 = 0x1 << 0
    let platformCategory: UInt32 = 0x1 << 1
    let groundCategory: UInt32 = 0x1 << 2

    // RCS attitude hold: extra angular damping while no rotation input is held.
    static let freeAngularDamping: CGFloat = 0.7
    static let rcsHoldAngularDamping: CGFloat = 2.6

    // MARK: - Init

    init(gameState: GameState, campaignState: CampaignState) {
        self.gameState = gameState
        self.campaignState = campaignState
        super.init(size: .zero)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear

        let gravity: CGFloat
        if gameState.currentMode.usesLevelDefinition,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            gravity = level.gravity
        } else {
            gravity = -2.0  // Classic mode default
        }
        physicsWorld.gravity = CGVector(dx: 0, dy: gravity)
        physicsWorld.contactDelegate = self

        setupScene()
        setupAccelerometer()
    }

    override func willMove(from view: SKView) {
        motionManager.stopAccelerometerUpdates()
        stopThrustSound()
    }

    private func setupAccelerometer() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 60.0
            motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
                guard let self = self, let data = data else { return }
                self.accelerometerTilt = CGFloat(data.acceleration.x)
            }
        }
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        if size.width > 0 && size.height > 0 && !gameState.gameOver {
            let sizeChanged = abs(oldSize.width - size.width) > 1 || abs(oldSize.height - size.height) > 1
            if oldSize == .zero || sizeChanged {
                removeAllChildren()
                setupScene()
            }
        }
    }

    // MARK: - Setup

    func setupScene() {
        guard size.width > 0 && size.height > 0 else { return }

        GameCenterManager.shared.clearLastLeaderboardRank()
        shipSkin = HangarManager.shared.selectedSkin
        setupCamera()
        createSky()
        createStarfield()
        createCelestialBody()
        createDistantRidge()
        createTerrain()
        createGround()
        createPlatforms()
        platformOriginalPositions = platforms.map { $0.position }
        createRocket()
        createFlightGuidance()

        hasStarted = false
        frameCounter = 0
        gameState.gameOver = false
        gameState.landed = false
        gameState.shouldReset = false
        gameState.fuel = 100
        gameState.score = 0
        gameState.verticalVelocity = 0
        gameState.horizontalVelocity = 0
        gameState.rotation = 0
        gameState.landedPlatform = nil
        gameState.landingMessage = ""
        gameState.starsEarned = 0
        gameState.flightStarted = false
        gameState.flightReward = nil

        maxDescentSpeed = 0
        recentVelocities = []
        lastTrackedVerticalSpeed = 0
        lastTrackedHorizontalSpeed = 0
        lastTrackedTilt = 0

        // Apply visual reentry state for level-based modes (tilt only — velocity applied on start)
        if gameState.currentMode.usesLevelDefinition {
            rocket.zRotation = CampaignReentryState.initialTilt
            gameState.tiltAngle = CampaignReentryState.initialTilt
            lastTrackedTilt = CampaignReentryState.initialTilt
        }

        stopThrustSound()
        wasRotatingLeft = false
        wasRotatingRight = false

        if gameState.currentMode.usesLevelDefinition,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            physicsWorld.gravity = CGVector(dx: 0, dy: level.gravity)
            startLevelEffects(level)
        } else {
            physicsWorld.gravity = CGVector(dx: 0, dy: -2.0)
        }

        if gameState.currentMode == .dailyChallenge,
           let target = gameState.dailyChallengeTargetPlatform {
            highlightTargetPlatform(target)
        }
    }

    // MARK: - Daily Challenge Target Highlight

    private func highlightTargetPlatform(_ target: LandingPlatform) {
        guard let platformIndex = LandingPlatform.allCases.firstIndex(of: target),
              platformIndex < platforms.count else { return }
        let platformNode = platforms[platformIndex]

        let ring = SKShapeNode(rectOf: CGSize(width: target.width + 16, height: 32), cornerRadius: 6)
        ring.strokeColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.8)
        ring.fillColor = .clear
        ring.lineWidth = 2
        ring.glowWidth = 4
        ring.position = CGPoint(x: 0, y: 0)
        ring.zPosition = 5
        ring.name = "targetRing"

        let pulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ])
        ring.run(SKAction.repeatForever(pulse))
        platformNode.addChild(ring)

        let label = SKLabelNode(text: "TARGET")
        label.fontSize = 11
        label.fontName = "Orbitron"
        label.fontColor = SKColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        label.position = CGPoint(x: 0, y: 24)
        label.zPosition = 5
        label.name = "targetLabel"

        let labelPulse = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 1.0),
            SKAction.fadeAlpha(to: 1.0, duration: 1.0)
        ])
        label.run(SKAction.repeatForever(labelPulse))
        platformNode.addChild(label)
    }

    private func beginFlight(at currentTime: TimeInterval) {
        hasStarted = true
        gameStartTime = currentTime
        rocket.physicsBody?.isDynamic = true
        applyCampaignReentryState()
        GameCenterManager.shared.recordAttempt(mode: gameState.currentMode, levelId: gameState.currentLevelId)
        DispatchQueue.main.async {
            self.gameState.flightStarted = true
        }
    }

    private func applyCampaignReentryState() {
        guard gameState.currentMode.usesLevelDefinition else { return }
        rocket.zRotation = CampaignReentryState.initialTilt
        rocket.physicsBody?.velocity = CGVector(
            dx: CampaignReentryState.initialHorizontalSpeed,
            dy: 0
        )
    }

    // MARK: - Level-Specific Effects

    private func startLevelEffects(_ level: LevelDefinition) {
        switch level.specialMechanic {
        case .lightWind:
            windForce = CGFloat.random(in: -1.5...1.5)
            createWindParticles(intensity: .light)
        case .heavyTurbulence:
            windForce = 0
            createWindParticles(intensity: .heavy)
        case .extremeWind:
            windForce = 0
            createWindParticles(intensity: .extreme)
        case .heatShimmer:
            createHeatShimmer()
        case .volcanicEruptions:
            createVolcanicEruption()
        case .denseAtmosphere:
            // Titan: dense atmosphere reduces thrust efficiency (handled in update loop)
            createAtmosphereHaze()
        case .cryogeysers:
            rocket.physicsBody?.friction = 0.01
            createIceShimmer()
            setupCryogeysers()
            createCryogeyserEffect()
        default:
            break
        }
    }

    // MARK: - Cryogeyser Setup (Europa)

    private func setupCryogeysers() {
        let fractions: [CGFloat] = [0.08, 0.34, 0.66]
        geyserPositions = fractions.map { $0 * size.width }
        geyserActive = [false, false, false]
        geyserTimers = [0.0, 1.5, 3.0]
        geyserActiveDurations = (0..<3).map { _ in Double.random(in: 2.0...3.0) }
        geyserCalmDurations = (0..<3).map { _ in Double.random(in: 3.0...5.0) }

        for x in geyserPositions {
            let vent = SKShapeNode(ellipseOf: CGSize(width: 12, height: 4))
            vent.fillColor = SKColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.6)
            vent.strokeColor = SKColor(red: 0.6, green: 0.8, blue: 1.0, alpha: 0.4)
            vent.position = CGPoint(x: x, y: 178)
            vent.zPosition = 6
            vent.name = "geyserVent"
            addChild(vent)
        }
    }

    // MARK: - Update Loop

    override func update(_ currentTime: TimeInterval) {
        guard !gameState.gameOver, rocket != nil else { return }

        #if DEBUG
        if DebugLaunch.autopilot { runAutopilot() }
        #endif

        // Auto-start on first input
        if !hasStarted && (gameState.isThrusting || gameState.isRotatingLeft || gameState.isRotatingRight) {
            beginFlight(at: currentTime)
        }

        guard hasStarted else { return }

        let dt = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 0
        lastUpdateTime = currentTime
        frameCounter += 1
        // Control inputs are tuned per 60 fps frame; scale by real elapsed time so
        // thrust, rotation and fuel burn stay identical when frames drop.
        let frameScale = CGFloat(min(dt, 0.05) * 60)

        if gameStartTime > 0 {
            gameState.elapsedTime = currentTime - gameStartTime
        }

        // Check for reset
        if gameState.shouldReset {
            gameState.shouldReset = false
            removeAllChildren()
            removeAllActions()
            geyserPositions = []
            geyserActive = []
            geyserTimers = []
            geyserActiveDurations = []
            geyserCalmDurations = []
            lastUpdateTime = 0
            gameStartTime = 0
            setupScene()
            return
        }

        // Main engine
        let thrusting = gameState.isThrusting && gameState.fuel > 0
        if thrusting {
            guard var velocity = rocket.physicsBody?.velocity else { return }

            var thrustPower: CGFloat
            if gameState.currentMode.usesLevelDefinition,
               let level = LevelDefinition.level(for: gameState.currentLevelId) {
                thrustPower = level.thrustPower
                // Titan (level 3): dense atmosphere reduces thrust efficiency by 25%
                if level.id == 3 {
                    thrustPower *= 0.75
                }
            } else {
                thrustPower = 12.0
            }
            thrustPower *= frameScale
            let angle = rocket.zRotation + .pi / 2
            velocity.dx += cos(angle) * thrustPower
            velocity.dy += sin(angle) * thrustPower

            // Proportional thrust vectoring — lateral force scales with tilt angle
            let lateralFactor: CGFloat = 0.15
            velocity.dx += sin(rocket.zRotation) * thrustPower * lateralFactor

            rocket.physicsBody?.velocity = velocity

            startThrustSound()
            HapticManager.shared.thrustPulse()

            DispatchQueue.main.async {
                self.gameState.fuel = max(0, self.gameState.fuel - 0.27 * Double(frameScale))
            }
        } else {
            stopThrustSound()
        }
        setEngine(on: thrusting)

        // Rotation
        var hasRotationInput = false
        if gameState.fuel > 0 {
            let rotationPower: CGFloat = 0.04 * frameScale

            if gameState.useAccelerometer {
                let deadZone: CGFloat = 0.1
                let sensitivity: CGFloat = 0.06

                if abs(accelerometerTilt) > deadZone {
                    hasRotationInput = true
                    let tiltAmount = accelerometerTilt - (accelerometerTilt > 0 ? deadZone : -deadZone)
                    rocket.physicsBody?.angularVelocity += tiltAmount * sensitivity * frameScale

                    let fuelConsumption = Double(abs(tiltAmount) * 0.035 * frameScale)
                    DispatchQueue.main.async {
                        self.gameState.fuel = max(0, self.gameState.fuel - fuelConsumption)
                    }
                }
            } else {
                if gameState.isRotatingLeft {
                    hasRotationInput = true
                    if !wasRotatingLeft {
                        playRotateSound()
                        HapticManager.shared.rotationStart()
                    }
                    rocket.physicsBody?.angularVelocity += rotationPower
                    DispatchQueue.main.async {
                        self.gameState.fuel = max(0, self.gameState.fuel - 0.07 * Double(frameScale))
                    }
                }

                if gameState.isRotatingRight {
                    hasRotationInput = true
                    if !wasRotatingRight {
                        playRotateSound()
                        HapticManager.shared.rotationStart()
                    }
                    rocket.physicsBody?.angularVelocity -= rotationPower
                    DispatchQueue.main.async {
                        self.gameState.fuel = max(0, self.gameState.fuel - 0.07 * Double(frameScale))
                    }
                }
            }
        }

        // RCS attitude hold: damp spin when the pilot lets go of rotation (needs fuel)
        let holdAttitude = !hasRotationInput && gameState.fuel > 0
        rocket.physicsBody?.angularDamping = holdAttitude ? GameScene.rcsHoldAngularDamping : GameScene.freeAngularDamping

        wasRotatingLeft = gameState.isRotatingLeft
        wasRotatingRight = gameState.isRotatingRight

        applyCampaignMechanics(dt: dt, currentTime: currentTime, frameScale: frameScale)

        // Track velocity (post-thrust, post-rotation, post-mechanics — authoritative snapshot)
        if let velocity = rocket.physicsBody?.velocity {
            let currentVerticalSpeed = max(0, -velocity.dy)

            if currentVerticalSpeed > maxDescentSpeed {
                maxDescentSpeed = currentVerticalSpeed
            }

            recentVelocities.append(currentVerticalSpeed)
            if recentVelocities.count > velocityHistorySize {
                recentVelocities.removeFirst()
            }

            lastTrackedVerticalSpeed = currentVerticalSpeed
            lastTrackedHorizontalSpeed = abs(velocity.dx)
            lastTrackedTilt = rocket.zRotation

            DispatchQueue.main.async {
                self.gameState.verticalVelocity = currentVerticalSpeed
                self.gameState.horizontalVelocity = abs(velocity.dx)
                self.gameState.rotation = abs(self.rocket.zRotation)
                self.gameState.tiltAngle = self.rocket.zRotation
            }
        }

        // Screen wrap
        if rocket.position.x < -20 {
            rocket.position.x = size.width + 20
        } else if rocket.position.x > size.width + 20 {
            rocket.position.x = -20
        }

        updateFlightGuidance(thrusting: thrusting)
        updateCamera(dt: dt)

        if rocket.position.y < -100 {
            crashRocket()
        }
    }

    // MARK: - Campaign Mechanics

    private func applyCampaignMechanics(dt: TimeInterval, currentTime: TimeInterval, frameScale: CGFloat) {
        guard gameState.currentMode.usesLevelDefinition,
              let level = LevelDefinition.level(for: gameState.currentLevelId) else { return }

        switch level.specialMechanic {
        case .lightWind:
            rocket.physicsBody?.applyForce(CGVector(dx: windForce, dy: 0))

        case .heavyTurbulence:
            // Venus: vertical updrafts/downdrafts
            windTime += dt
            let verticalForce = CGFloat(sin(windTime * 1.5)) * 4.0 + CGFloat.random(in: -0.5...0.5)
            rocket.physicsBody?.applyForce(CGVector(dx: 0, dy: verticalForce))

        case .extremeWind:
            // Jupiter: sudden gusts pushing left→right with calm windows
            gustTimer += dt
            if gustActive {
                let gustForce: CGFloat = 20.0 + CGFloat.random(in: -3...3)
                rocket.physicsBody?.applyForce(CGVector(dx: gustForce, dy: 0))
                if gustTimer >= gustActiveDuration {
                    gustActive = false
                    gustTimer = 0
                    gustCalmDuration = Double.random(in: 2.0...3.5)
                }
            } else {
                rocket.physicsBody?.applyForce(CGVector(dx: CGFloat.random(in: 0.5...2), dy: 0))
                if gustTimer >= gustCalmDuration {
                    gustActive = true
                    gustTimer = 0
                    gustActiveDuration = Double.random(in: 1.5...2.5)
                    showHazardWarning("GUST")
                }
            }

        case .heatShimmer:
            // Mercury: heat interference — random perturbation when thrusting
            if gameState.isThrusting && gameState.fuel > 0 {
                rocket.physicsBody?.velocity.dx += CGFloat.random(in: -3.5...3.5) * frameScale
                rocket.physicsBody?.velocity.dy += CGFloat.random(in: -2.0...2.0) * frameScale
                rocket.physicsBody?.angularVelocity += CGFloat.random(in: -0.02...0.02) * frameScale
            }

        case .cryogeysers:
            for i in 0..<geyserPositions.count {
                geyserTimers[i] += dt
                if geyserActive[i] {
                    if geyserTimers[i] >= geyserActiveDurations[i] {
                        geyserActive[i] = false
                        geyserTimers[i] = 0
                        geyserCalmDurations[i] = Double.random(in: 3.0...5.0)
                    }
                    let gx = geyserPositions[i]
                    let horizontalRange: CGFloat = 30
                    let plumeBottom: CGFloat = 180
                    let plumeTop: CGFloat = 480
                    if let rocketPos = rocket?.position,
                       abs(rocketPos.x - gx) < horizontalRange,
                       rocketPos.y >= plumeBottom && rocketPos.y <= plumeTop {
                        let heightFraction = 1.0 - (rocketPos.y - plumeBottom) / (plumeTop - plumeBottom)
                        let upwardForce = 18.0 * heightFraction
                        let lateralJitter = CGFloat.random(in: -1.5...1.5)
                        rocket.physicsBody?.applyForce(CGVector(dx: lateralJitter, dy: upwardForce))
                    }
                } else if geyserTimers[i] >= geyserCalmDurations[i] {
                    geyserActive[i] = true
                    geyserTimers[i] = 0
                    geyserActiveDurations[i] = Double.random(in: 2.0...3.0)
                }
            }

        case .movingPlatform:
            // A: vertical bob · B: horizontal sway · C: diagonal
            let speeds: [CGFloat] = [15, 30, 25]
            let vRange: CGFloat = 18
            let zoneBLeft = size.width * 0.35
            let zoneBRight = size.width * 0.65
            let zoneCLeft = size.width * 0.70

            for (i, plat) in platforms.enumerated() {
                guard i < platformOriginalPositions.count && i < platformDirections.count else { continue }
                let origin = platformOriginalPositions[i]
                let speed = speeds[min(i, speeds.count - 1)]

                if i == 0 {
                    plat.position.y += platformDirections[i] * speed * CGFloat(dt)
                    if abs(plat.position.y - origin.y) > vRange {
                        platformDirections[i] *= -1
                    }
                } else if i == 1 {
                    plat.position.x += platformDirections[i] * speed * CGFloat(dt)
                    let halfWidth = LandingPlatform.allCases[1].width / 2
                    let minX = zoneBLeft + halfWidth
                    let maxX = zoneBRight - halfWidth
                    if plat.position.x <= minX || plat.position.x >= maxX {
                        platformDirections[i] *= -1
                        plat.position.x = max(minX, min(maxX, plat.position.x))
                    }
                } else {
                    plat.position.x += platformDirections[i] * speed * CGFloat(dt)
                    plat.position.y = origin.y + CGFloat(sin(currentTime * 1.5)) * vRange
                    let halfWidth = LandingPlatform.allCases[2].width / 2
                    let minX = zoneCLeft + halfWidth
                    let maxX = size.width - halfWidth - 10
                    if plat.position.x <= minX || plat.position.x >= maxX {
                        platformDirections[i] *= -1
                        plat.position.x = max(minX, min(maxX, plat.position.x))
                    }
                }
            }

        default:
            break
        }
    }

    // MARK: - Collision

    func didBegin(_ contact: SKPhysicsContact) {
        guard !gameState.gameOver else { return }

        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == rocketCategory | platformCategory {
            let platformNode: SKNode?
            if contact.bodyA.categoryBitMask == platformCategory {
                platformNode = contact.bodyA.node
            } else {
                platformNode = contact.bodyB.node
            }
            checkLanding(contactNode: platformNode)
        } else if collision == rocketCategory | groundCategory {
            crashRocket()
        }
    }

    private func checkLanding(contactNode: SKNode?) {
        let landedPlatform = determineLandedPlatform(contactNode: contactNode) ?? .a
        let platformCenterX = contactNode?.position.x ?? landedPlatform.xFraction * size.width

        // Both legs must be on the platform (feet at ±23.5 from center)
        let legSpan: CGFloat = 47
        let rocketLeft = rocket.position.x - legSpan / 2
        let rocketRight = rocket.position.x + legSpan / 2
        let platformHalfWidth = landedPlatform.width / 2
        let platformLeft = platformCenterX - platformHalfWidth
        let platformRight = platformCenterX + platformHalfWidth

        if rocketLeft < platformLeft || rocketRight > platformRight {
            snapshotFinalStats(platform: nil)
            gameState.crashDiagnosticPrimary = "Missed the platform!"
            gameState.crashDiagnosticSecondary = "Both legs must be on the platform to land safely."
            crashRocket()
            return
        }

        // Pre-contact tracked values reflect touchdown speed before collision resolution
        let verticalSpeed = lastTrackedVerticalSpeed
        let horizontalSpeed = lastTrackedHorizontalSpeed
        let rotation = abs(lastTrackedTilt)

        let approachSpeed = recentVelocities.isEmpty ? verticalSpeed : recentVelocities.reduce(0, +) / CGFloat(recentVelocities.count)

        DispatchQueue.main.async {
            self.gameState.verticalVelocity = verticalSpeed
            self.gameState.horizontalVelocity = horizontalSpeed
            self.gameState.rotation = rotation
        }

        let result = LandingThresholds.evaluate(
            verticalSpeed: verticalSpeed,
            horizontalSpeed: horizontalSpeed,
            rotation: rotation,
            platform: landedPlatform
        )

        if result.success {
            successfulLanding(
                verticalSpeed: verticalSpeed,
                horizontalSpeed: horizontalSpeed,
                rotation: rotation,
                approachSpeed: approachSpeed,
                platform: landedPlatform,
                speedBand: result.speedBand,
                platformCenterX: platformCenterX
            )
        } else {
            snapshotFinalStats(platform: nil)

            let diagnostic = LandingMessages.diagnosticCrashMessage(
                verticalSpeed: gameState.finalVerticalSpeed,
                horizontalSpeed: gameState.finalHorizontalSpeed,
                rotation: abs(gameState.finalTiltAngle),
                approachSpeed: approachSpeed,
                platform: landedPlatform,
                hitTerrain: false
            )
            gameState.crashDiagnosticPrimary = diagnostic.primaryMessage
            gameState.crashDiagnosticSecondary = diagnostic.secondaryHint ?? ""

            crashRocket()
        }
    }

    private func snapshotFinalStats(platform: LandingPlatform?, platformCenterX: CGFloat? = nil) {
        gameState.finalTiltAngle = lastTrackedTilt  // signed (preserves direction)
        gameState.finalVerticalSpeed = lastTrackedVerticalSpeed
        gameState.finalHorizontalSpeed = lastTrackedHorizontalSpeed
        gameState.finalFuel = gameState.fuel
        if let platform = platform {
            let platformX = platformCenterX ?? platform.xFraction * size.width
            gameState.finalDistanceFromCenter = abs(rocket.position.x - platformX)
        } else {
            gameState.finalDistanceFromCenter = nil
        }
    }

    private func successfulLanding(verticalSpeed: CGFloat, horizontalSpeed: CGFloat, rotation: CGFloat, approachSpeed: CGFloat, platform: LandingPlatform, speedBand: SpeedBand, platformCenterX: CGFloat? = nil) {
        snapshotFinalStats(platform: platform, platformCenterX: platformCenterX)

        gameState.gameOver = true
        gameState.landed = true

        rocket.physicsBody?.isDynamic = false
        setEngine(on: false)
        stopThrustSound()
        hideFlightGuidance()

        let isDailyChallenge = gameState.currentMode == .dailyChallenge
        if !isDailyChallenge {
            playSuccessSound()
        }
        HapticManager.shared.landingSuccess()

        let elapsed = self.lastUpdateTime - self.gameStartTime

        let totalScore = calculateScore(
            verticalSpeed: verticalSpeed,
            horizontalSpeed: horizontalSpeed,
            rotation: rotation,
            approachSpeed: approachSpeed,
            platform: platform,
            speedBand: speedBand,
            elapsedTime: elapsed,
            platformCenterX: platformCenterX
        )

        let message = LandingMessages.successMessage(platform: platform, score: totalScore, speedBand: speedBand)

        DispatchQueue.main.async {
            self.gameState.score = totalScore
            self.gameState.landedPlatform = platform
            self.gameState.starsEarned = platform.stars
            self.gameState.landingMessage = message
            self.gameState.landingSpeedBand = speedBand
            self.gameState.elapsedTime = elapsed

            var challengeSuccess = false
            switch self.gameState.currentMode {
            case .campaign:
                self.campaignState.recordCompletion(
                    self.gameState.currentLevelId,
                    stars: platform.stars,
                    score: totalScore
                )
                self.gameState.campaignMilestoneRewards = BlueStarManager.shared.checkCampaignMilestones(
                    totalCampaignStars: self.campaignState.totalStars
                )
                GameCenterManager.shared.submitCampaignScore(totalScore, levelId: self.gameState.currentLevelId, campaignState: self.campaignState)
            case .dailyChallenge:
                challengeSuccess = DailyChallenge.evaluate(
                    platform: platform,
                    tiltRadians: rotation,
                    verticalSpeed: verticalSpeed,
                    horizontalSpeed: horizontalSpeed,
                    fuel: self.gameState.fuel,
                    elapsedTime: elapsed
                )
                self.gameState.dailyChallengeSuccess = challengeSuccess
                if challengeSuccess {
                    self.playSuccessSound()
                    GameCenterManager.shared.submitDailyChallengeScore(totalScore)
                    let playerName = GameCenterManager.shared.localPlayerName
                    self.gameState.dailyChallengeWasNewBest = {
                        guard let best = DailyChallenge.localBestScore else { return true }
                        return totalScore > best
                    }()
                    DailyChallenge.recordScore(totalScore, success: true, playerName: playerName)
                    self.gameState.dailyRewardResult = BlueStarManager.shared.recordDailyChallengeCompletion()
                } else {
                    self.playChallengeFailSound()
                }
            case .classic:
                GameCenterManager.shared.submitClassicScore(totalScore)
            }

            GameCenterManager.shared.checkAchievements(
                compositeBand: speedBand,
                platform: platform,
                fuel: self.gameState.fuel,
                tilt: rotation,
                mode: self.gameState.currentMode,
                levelId: self.gameState.currentLevelId,
                campaignState: self.campaignState
            )

            self.gameState.flightReward = PilotProgress.shared.recordFlight(FlightOutcome(
                landed: true,
                platform: platform,
                speedBand: speedBand,
                mode: self.gameState.currentMode,
                challengeSuccess: challengeSuccess
            ))
        }

        createTouchdownEffect(platform: platform, speedBand: speedBand)
    }

    private func crashRocket() {
        guard !gameState.gameOver else { return }

        // Only snapshot and compute diagnostics if not already set by checkLanding
        if gameState.crashDiagnosticPrimary.isEmpty {
            snapshotFinalStats(platform: nil)

            let verticalSpeed = gameState.finalVerticalSpeed
            let horizontalSpeed = gameState.finalHorizontalSpeed
            let rotation = abs(gameState.finalTiltAngle)
            let approachSpeed = recentVelocities.isEmpty ? verticalSpeed : recentVelocities.reduce(0, +) / CGFloat(recentVelocities.count)
            let hitTerrain = rocket.position.y > -50

            let diagnostic = LandingMessages.diagnosticCrashMessage(
                verticalSpeed: verticalSpeed,
                horizontalSpeed: horizontalSpeed,
                rotation: rotation,
                approachSpeed: approachSpeed,
                platform: nil,
                hitTerrain: hitTerrain
            )

            gameState.crashDiagnosticPrimary = diagnostic.primaryMessage
            gameState.crashDiagnosticSecondary = diagnostic.secondaryHint ?? ""
        }

        gameState.gameOver = true
        gameState.landed = false

        rocket.physicsBody?.isDynamic = false
        setEngine(on: false)
        stopThrustSound()
        hideFlightGuidance()

        playExplosionSound()
        HapticManager.shared.crash()

        let mode = gameState.currentMode
        DispatchQueue.main.async {
            self.gameState.landingMessage = self.gameState.crashDiagnosticPrimary
            self.gameState.flightReward = PilotProgress.shared.recordFlight(FlightOutcome(
                landed: false,
                platform: nil,
                speedBand: .fail,
                mode: mode,
                challengeSuccess: false
            ))
        }

        createExplosion(at: rocket.position)
        rocket.alpha = 0
    }
}
