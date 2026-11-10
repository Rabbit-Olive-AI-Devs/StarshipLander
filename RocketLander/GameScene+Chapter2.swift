import SpriteKit
import UIKit

// MARK: - Chapter 2 mechanics, atmosphere model and ghost replay
extension GameScene {

    /// Level definition for campaign / daily modes (nil in Classic).
    var activeLevel: LevelDefinition? {
        guard gameState.currentMode.usesLevelDefinition else { return nil }
        return LevelDefinition.level(for: gameState.currentLevelId)
    }

    /// Spawn attitude: per-level override (belly flop) or the standard reentry tilt.
    var spawnTilt: CGFloat {
        guard let level = activeLevel else { return 0 }
        return level.initialTilt ?? CampaignReentryState.initialTilt
    }

    // MARK: Atmosphere

    /// Quadratic drag scaled by attitude: sideways (belly first) ≈ 5.5× the area of upright.
    /// Tuned so Earth density 1.0 gives ~150 pts/s belly-flop terminal velocity.
    static let dragCoefficient: CGFloat = 0.0187

    static func dragArea(tilt: CGFloat) -> CGFloat {
        0.18 + 0.82 * abs(sin(tilt))
    }

    func applyAtmosphere(dt: TimeInterval) {
        guard let density = activeLevel?.atmosphere, density > 0,
              var v = rocket.physicsBody?.velocity else { return }
        let speed = hypot(v.dx, v.dy)
        guard speed > 1 else { return }
        let c = GameScene.dragCoefficient * density * GameScene.dragArea(tilt: rocket.zRotation)
        let dv = min(speed, c * speed * speed * CGFloat(min(dt, GameScene.maxStep)))
        v.dx -= v.dx / speed * dv
        v.dy -= v.dy / speed * dv
        rocket.physicsBody?.velocity = v
        updatePlasma(speed: speed, velocity: v, density: density)
    }

    /// Reentry plasma on the leading face when falling fast through air.
    private func updatePlasma(speed: CGFloat, velocity: CGVector, density: CGFloat) {
        if plasmaGlow == nil {
            let glow = SKSpriteNode(texture: StarshipArt.softDot)
            glow.size = CGSize(width: 90, height: 60)
            glow.color = SKColor(red: 1.0, green: 0.45, blue: 0.75, alpha: 1)
            glow.colorBlendFactor = 1
            glow.blendMode = .add
            glow.alpha = 0
            glow.zPosition = 11
            addChild(glow)
            plasmaGlow = glow
        }
        guard let glow = plasmaGlow else { return }
        let intensity = max(0, min(1, (speed - 200) / 220)) * min(1, density + 0.3)
        glow.alpha = intensity * CGFloat.random(in: 0.75...1.0)
        let dir = CGVector(dx: velocity.dx / speed, dy: velocity.dy / speed)
        glow.position = CGPoint(x: rocket.position.x + dir.dx * 30, y: rocket.position.y + dir.dy * 30)
        glow.zRotation = atan2(dir.dy, dir.dx) + .pi / 2
        glow.setScale(0.8 + intensity * 0.6)
    }

    func hidePlasma() {
        plasmaGlow?.alpha = 0
    }

    // MARK: Level setup

    func startChapter2Effects(_ level: LevelDefinition) {
        switch level.specialMechanic {
        case .towerCatch:
            setupTowerCatch()
        case .meteorShower:
            startMeteorShower()
        case .nightLanding:
            setupNightLanding()
        default:
            break
        }
    }

    // MARK: Tower catch (Starbase)

    private func setupTowerCatch() {
        guard platforms.count == 3 else { return }
        let pad = platforms[2]
        let padWidth = LandingPlatform.c.width
        let padTop = pad.position.y + 4
        let towerWidth: CGFloat = 24
        // Keep the whole tower on screen; the arms reach back over the catch rails
        let towerX = min(pad.position.x + padWidth / 2 + 30, size.width - towerWidth / 2 - 2)
        let towerHeight: CGFloat = min(size.height * 0.62, 560)

        // Catch rails replace the pad look
        pad.fillColor = SKColor(red: 0.16, green: 0.17, blue: 0.19, alpha: 1)
        pad.strokeColor = SKColor(red: 0.45, green: 0.47, blue: 0.5, alpha: 1)
        for case let label as SKLabelNode in pad.children where label.text == LandingPlatform.c.label {
            label.text = "Tower Catch"
        }

        // Lattice tower
        let tower = SKNode()
        tower.position = CGPoint(x: towerX, y: 0)
        tower.zPosition = 2.5
        let frame = SKShapeNode(rect: CGRect(x: -towerWidth / 2, y: 0, width: towerWidth, height: towerHeight))
        frame.fillColor = SKColor(red: 0.13, green: 0.14, blue: 0.16, alpha: 1)
        frame.strokeColor = SKColor(red: 0.42, green: 0.44, blue: 0.48, alpha: 1)
        frame.lineWidth = 1.5
        tower.addChild(frame)
        let bracing = CGMutablePath()
        var y: CGFloat = 0
        while y < towerHeight - 20 {
            bracing.move(to: CGPoint(x: -towerWidth / 2, y: y))
            bracing.addLine(to: CGPoint(x: towerWidth / 2, y: y + 20))
            bracing.move(to: CGPoint(x: towerWidth / 2, y: y))
            bracing.addLine(to: CGPoint(x: -towerWidth / 2, y: y + 20))
            bracing.move(to: CGPoint(x: -towerWidth / 2, y: y + 20))
            bracing.addLine(to: CGPoint(x: towerWidth / 2, y: y + 20))
            y += 20
        }
        let lattice = SKShapeNode(path: bracing)
        lattice.strokeColor = SKColor(red: 0.38, green: 0.4, blue: 0.44, alpha: 0.9)
        lattice.lineWidth = 0.8
        tower.addChild(lattice)

        // Aviation light on top
        let beacon = SKSpriteNode(texture: StarshipArt.softDot)
        beacon.size = CGSize(width: 18, height: 18)
        beacon.color = .red
        beacon.colorBlendFactor = 1
        beacon.blendMode = .add
        beacon.position = CGPoint(x: 0, y: towerHeight + 4)
        beacon.run(.repeatForever(.sequence([.fadeAlpha(to: 0.15, duration: 0.6), .fadeAlpha(to: 1, duration: 0.15)])))
        tower.addChild(beacon)
        addChild(tower)

        // Chopstick arms (front + back), parked upright against the tower until the catch
        towerArms = []
        let armLength = (towerX - towerWidth / 2) - (pad.position.x - padWidth / 2) + 6
        for (offset, shade) in [(CGFloat(3), CGFloat(0.22)), (CGFloat(0), CGFloat(0.32))] {
            let arm = SKNode()
            arm.position = CGPoint(x: towerX - towerWidth / 2, y: padTop + 32 + offset)
            arm.zPosition = offset > 0 ? 9 : 11
            let beam = SKShapeNode(rect: CGRect(x: -armLength, y: -3, width: armLength, height: 6), cornerRadius: 2)
            beam.fillColor = SKColor(white: shade, alpha: 1)
            beam.strokeColor = SKColor(white: shade + 0.2, alpha: 1)
            beam.lineWidth = 1
            arm.addChild(beam)
            let grip = SKShapeNode(rect: CGRect(x: -armLength, y: -5, width: 10, height: 10), cornerRadius: 2)
            grip.fillColor = SKColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1)
            grip.strokeColor = .clear
            arm.addChild(grip)
            arm.zRotation = -1.35
            addChild(arm)
            towerArms.append(arm)
        }
    }

    /// Swings the chopsticks closed around the ship after a successful tower catch.
    func closeChopsticks() {
        for (i, arm) in towerArms.enumerated() {
            let close = SKAction.rotate(toAngle: 0, duration: 0.35, shortestUnitArc: true)
            close.timingMode = .easeIn
            arm.run(SKAction.sequence([SKAction.wait(forDuration: Double(i) * 0.06), close]))
        }
        run(SKAction.sequence([SKAction.wait(forDuration: 0.4), SKAction.run { [weak self] in
            self?.shakeCamera(intensity: 4, duration: 0.2)
            HapticManager.shared.rotationStart()
        }]))
    }

    var isTowerCatchLevel: Bool { activeLevel?.specialMechanic == .towerCatch }

    // MARK: Meteor shower (Ceres)

    private func startMeteorShower() {
        let loop = SKAction.sequence([
            SKAction.wait(forDuration: 1.6, withRange: 1.2),
            SKAction.run { [weak self] in self?.spawnMeteor() }
        ])
        run(SKAction.repeatForever(loop), withKey: "meteorShower")
    }

    private func spawnMeteor() {
        guard !gameState.gameOver, rocket != nil else { return }
        // Bias some meteors toward the ship so loitering is dangerous
        let targetX: CGFloat = Bool.random()
            ? rocket.position.x + CGFloat.random(in: -60...60)
            : CGFloat.random(in: 20...(size.width - 20))
        let groundY = surfaceHeightIgnoringPads(at: targetX)
        let startPoint = CGPoint(x: targetX + 140, y: size.height + 40)

        // Warning marker at the top of the screen
        let warning = SKLabelNode(fontNamed: "Orbitron")
        warning.text = "\u{25BC}"
        warning.fontSize = 18
        warning.fontColor = SKColor(red: 1, green: 0.25, blue: 0.2, alpha: 1)
        warning.position = CGPoint(x: targetX, y: size.height - 150)
        warning.zPosition = 40
        addChild(warning)
        warning.run(SKAction.sequence([
            SKAction.repeat(SKAction.sequence([SKAction.fadeAlpha(to: 0.2, duration: 0.12), SKAction.fadeAlpha(to: 1, duration: 0.12)]), count: 4),
            SKAction.removeFromParent()
        ]))

        let meteor = SKSpriteNode(texture: StarshipArt.softDot)
        let radius = CGFloat.random(in: 6...10)
        meteor.size = CGSize(width: radius * 2.6, height: radius * 2.6)
        meteor.color = SKColor(red: 1, green: 0.7, blue: 0.4, alpha: 1)
        meteor.colorBlendFactor = 1
        meteor.blendMode = .add
        meteor.position = startPoint
        meteor.zPosition = 15
        meteor.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        meteor.physicsBody?.isDynamic = false
        meteor.physicsBody?.categoryBitMask = groundCategory
        meteor.physicsBody?.contactTestBitMask = rocketCategory

        let trail = SKEmitterNode()
        trail.particleTexture = StarshipArt.softDot
        trail.particleBirthRate = 140
        trail.particleLifetime = 0.45
        trail.particleSpeed = 0
        trail.particleScale = 0.5
        trail.particleScaleSpeed = -0.9
        trail.particleAlpha = 0.8
        trail.particleAlphaSpeed = -1.6
        trail.particleBlendMode = .add
        trail.particleColor = SKColor(red: 1, green: 0.5, blue: 0.2, alpha: 1)
        trail.particleColorBlendFactor = 1
        meteor.addChild(trail)
        addChild(meteor)
        trail.targetNode = self

        let fall = SKAction.move(to: CGPoint(x: targetX, y: groundY), duration: 1.25)
        fall.timingMode = .easeIn
        meteor.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.9),
            fall,
            SKAction.run { [weak self] in self?.meteorImpact(at: CGPoint(x: targetX, y: groundY)) },
            SKAction.removeFromParent()
        ]))
    }

    private func meteorImpact(at point: CGPoint) {
        let flash = SKSpriteNode(texture: StarshipArt.softDot)
        flash.size = CGSize(width: 80, height: 40)
        flash.color = SKColor(red: 1, green: 0.75, blue: 0.4, alpha: 1)
        flash.colorBlendFactor = 1
        flash.blendMode = .add
        flash.position = point
        flash.zPosition = 16
        addChild(flash)
        flash.run(SKAction.sequence([SKAction.group([SKAction.scale(to: 1.8, duration: 0.3), SKAction.fadeOut(withDuration: 0.3)]), SKAction.removeFromParent()]))

        let dust = makeDustEmitter()
        dust.position = point
        dust.particleBirthRate = 600
        dust.numParticlesToEmit = 30
        addChild(dust)
        dust.run(SKAction.sequence([SKAction.wait(forDuration: 1.2), SKAction.removeFromParent()]))

        let distance = hypot(rocket.position.x - point.x, rocket.position.y - point.y)
        if distance < 220 {
            shakeCamera(intensity: 5 * (1 - distance / 220), duration: 0.15)
        }
    }

    /// Terrain height ignoring pads (meteors hit the ground, pads included).
    private func surfaceHeightIgnoringPads(at x: CGFloat) -> CGFloat {
        guard !terrainHeights.isEmpty else { return 10 }
        let i = max(0, min(terrainHeights.count - 1, Int(x / terrainSegmentWidth)))
        return terrainHeights[i]
    }

    // MARK: Night landing (Mars Night)

    private static let darknessTexture: SKTexture = {
        let size = CGSize(width: 512, height: 512)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let colors = [
                UIColor.black.withAlphaComponent(0).cgColor,
                UIColor.black.withAlphaComponent(0).cgColor,
                UIColor.black.withAlphaComponent(0.96).cgColor,
                UIColor.black.withAlphaComponent(0.96).cgColor,
            ] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.025, 0.09, 1]) else { return }
            let center = CGPoint(x: 256, y: 256)
            ctx.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: 362, options: [.drawsAfterEndLocation])
        }
        return SKTexture(image: image)
    }()

    private func setupNightLanding() {
        let side = max(size.width, size.height) * 3.2
        let darkness = SKSpriteNode(texture: GameScene.darknessTexture)
        darkness.size = CGSize(width: side, height: side)
        darkness.position = rocket.position
        darkness.zPosition = 25
        addChild(darkness)
        darknessOverlay = darkness

        // Warm pool of light thrown on the ground by the ship's landing light
        let pool = SKSpriteNode(texture: StarshipArt.softDot)
        pool.size = CGSize(width: 150, height: 34)
        pool.color = SKColor(red: 1, green: 0.92, blue: 0.75, alpha: 1)
        pool.colorBlendFactor = 1
        pool.blendMode = .add
        pool.alpha = 0
        pool.zPosition = 26
        addChild(pool)
        landingLightPool = pool

        // Pad beacons shine through the darkness
        for (i, node) in platforms.enumerated() where i < LandingPlatform.allCases.count {
            let platform = LandingPlatform.allCases[i]
            for side in [-1, 1] {
                let beacon = SKSpriteNode(texture: StarshipArt.softDot)
                beacon.size = CGSize(width: 16, height: 16)
                beacon.color = platform.lightColor
                beacon.colorBlendFactor = 1
                beacon.blendMode = .add
                beacon.position = CGPoint(x: CGFloat(side) * (platform.width / 2 - 8), y: 8)
                beacon.zPosition = 28 - node.zPosition
                beacon.run(.repeatForever(.sequence([.fadeAlpha(to: 0.35, duration: 0.5), .fadeAlpha(to: 1, duration: 0.5)])))
                node.addChild(beacon)
            }
        }

        windForce = CGFloat.random(in: -1.2...1.2)
        createWindParticles(intensity: .light)
    }

    func updateNightLanding() {
        guard let darkness = darknessOverlay else { return }
        darkness.position = rocket.position
        if let pool = landingLightPool {
            let altitude = altitudeAboveSurface()
            pool.position = CGPoint(x: rocket.position.x, y: surfaceHeight(at: rocket.position.x) + 2)
            pool.alpha = max(0, 1 - altitude / 320) * 0.85
        }
    }

    // MARK: Ghost replay

    func startGhost() {
        ghostSamples = []
        lastGhostSampleTime = -1
        ghostNode?.removeFromParent()
        ghostNode = nil
        guard let key = GhostStore.key(mode: gameState.currentMode, levelId: gameState.currentLevelId),
              let run = GhostStore.load(key: key) else {
            ghostRun = nil
            return
        }
        ghostRun = run
        let ghost = StarshipArt.makeShip(skin: .europaIce)
        ghost.alpha = 0.28
        ghost.zPosition = 9
        let tag = SKLabelNode(fontNamed: "Orbitron")
        tag.text = "BEST \(run.score)"
        tag.fontSize = 9
        tag.fontColor = SKColor(red: 0.6, green: 0.9, blue: 1, alpha: 1)
        tag.position = CGPoint(x: 0, y: 48)
        ghost.addChild(tag)
        ghost.isHidden = true
        addChild(ghost)
        ghostNode = ghost
    }

    /// Records the live flight and moves the ghost along the best run.
    func updateGhost(flightTime: TimeInterval) {
        if flightTime - lastGhostSampleTime >= GhostRun.sampleInterval || lastGhostSampleTime < 0,
           ghostSamples.count < GhostRun.maxSamples {
            ghostSamples.append(GhostSample(x: Float(rocket.position.x), y: Float(rocket.position.y), r: Float(rocket.zRotation)))
            lastGhostSampleTime = flightTime
        }

        guard let ghost = ghostNode, let run = ghostRun else { return }
        if let pose = run.pose(at: flightTime, width: Float(size.width)) {
            ghost.isHidden = false
            ghost.position = CGPoint(x: CGFloat(pose.x), y: CGFloat(pose.y))
            ghost.zRotation = CGFloat(pose.r)
        } else if !ghost.isHidden && ghost.action(forKey: "ghostDone") == nil {
            ghost.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.6), SKAction.hide()]), withKey: "ghostDone")
        }
    }

    /// Stores this flight as the new ghost when it beats the saved one.
    func saveGhostIfBest(score: Int) {
        guard let key = GhostStore.key(mode: gameState.currentMode, levelId: gameState.currentLevelId) else { return }
        ghostSamples.append(GhostSample(x: Float(rocket.position.x), y: Float(rocket.position.y), r: Float(rocket.zRotation)))
        GhostStore.saveIfBest(GhostRun(score: score, sceneWidth: Float(size.width), samples: ghostSamples), key: key)
    }
}
