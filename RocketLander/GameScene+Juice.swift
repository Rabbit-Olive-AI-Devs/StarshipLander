import SpriteKit

// MARK: - Camera, Flight Guidance & Feedback
extension GameScene {

    // MARK: Camera

    /// Zoom applied at touchdown altitude (1.0 = full screen).
    static let landingZoom: CGFloat = 0.84
    /// Altitude (pts above the surface) where the cinematic zoom begins.
    static let zoomStartAltitude: CGFloat = 260

    func setupCamera() {
        let cam = SKCameraNode()
        cam.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cam)
        camera = cam
        cameraNode = cam
    }

    /// Eases the camera toward the ship as it approaches the surface.
    /// The view always stays inside the scene bounds.
    func updateCamera(dt: TimeInterval) {
        guard let cam = cameraNode, rocket != nil else { return }

        let altitude = altitudeAboveSurface()
        let t = max(0, min(1, (GameScene.zoomStartAltitude - altitude) / GameScene.zoomStartAltitude))
        let eased = t * t * (3 - 2 * t)
        let targetScale = 1 - (1 - GameScene.landingZoom) * eased

        let blend = CGFloat(min(1, dt * 3.5))
        let scale = cam.xScale + (targetScale - cam.xScale) * blend
        cam.setScale(scale)

        let halfW = size.width * scale / 2
        let halfH = size.height * scale / 2
        let target = CGPoint(
            x: max(halfW, min(size.width - halfW, rocket.position.x)),
            y: max(halfH, min(size.height - halfH, rocket.position.y))
        )
        cam.position = CGPoint(
            x: cam.position.x + (target.x - cam.position.x) * blend,
            y: cam.position.y + (target.y - cam.position.y) * blend
        )
    }

    func shakeCamera(intensity: CGFloat, duration: TimeInterval) {
        guard let cam = cameraNode else { return }
        let steps = max(2, Int(duration / 0.04))
        var actions: [SKAction] = []
        for i in 0..<steps {
            let falloff = 1 - CGFloat(i) / CGFloat(steps)
            let dx = CGFloat.random(in: -1...1) * intensity * falloff
            let dy = CGFloat.random(in: -1...1) * intensity * falloff
            actions.append(SKAction.moveBy(x: dx, y: dy, duration: 0.02))
            actions.append(SKAction.moveBy(x: -dx, y: -dy, duration: 0.02))
        }
        cam.run(SKAction.sequence(actions), withKey: "shake")
    }

    // MARK: Surface Queries

    /// Index of the pad currently under the ship, if any.
    func padUnderShip() -> Int? {
        for (i, node) in platforms.enumerated() where i < LandingPlatform.allCases.count {
            let half = LandingPlatform.allCases[i].width / 2
            if abs(rocket.position.x - node.position.x) <= half {
                return i
            }
        }
        return nil
    }

    /// Height of whatever the ship would land on directly below it (pad top or terrain).
    func surfaceHeight(at x: CGFloat) -> CGFloat {
        if let pad = padUnderShip() {
            return platforms[pad].position.y + 4
        }
        guard !terrainHeights.isEmpty else { return 10 }
        let position = max(0, x) / terrainSegmentWidth
        let i = min(terrainHeights.count - 1, Int(position))
        let j = min(terrainHeights.count - 1, i + 1)
        let f = position - CGFloat(i)
        return terrainHeights[i] + (terrainHeights[j] - terrainHeights[i]) * f
    }

    func altitudeAboveSurface() -> CGFloat {
        let feetY = rocket.position.y + StarshipArt.feetBottomY
        return max(0, feetY - surfaceHeight(at: rocket.position.x))
    }

    // MARK: Flight Guidance

    func createFlightGuidance() {
        let line = SKSpriteNode(color: .white, size: CGSize(width: 1.5, height: 1))
        line.anchorPoint = CGPoint(x: 0.5, y: 1)
        line.alpha = 0
        line.zPosition = 8
        addChild(line)
        guidanceLine = line

        let label = SKLabelNode(fontNamed: "Orbitron")
        label.fontSize = 11
        label.horizontalAlignmentMode = .left
        label.verticalAlignmentMode = .center
        label.alpha = 0
        label.zPosition = 30
        addChild(label)
        guidanceLabel = label

        let dust = makeDustEmitter()
        dust.particleBirthRate = 0
        addChild(dust)
        dust.targetNode = self
        dustEmitter = dust
    }

    /// Descent line to the surface (green when both legs fit the pad below),
    /// a speed/altitude readout beside the ship, and engine dust near the ground.
    func updateFlightGuidance(thrusting: Bool) {
        guard let line = guidanceLine, let label = guidanceLabel else { return }

        let groundY = surfaceHeight(at: rocket.position.x)
        let feetY = rocket.position.y + StarshipArt.feetBottomY
        let altitude = max(0, feetY - groundY)
        let showGuidance = altitude < 340 && altitude > 2

        // Descent line color: does the ship fit the pad below?
        var lineColor = SKColor.white
        var lineAlpha: CGFloat = 0.22
        let pad = padUnderShip()
        if let i = pad {
            let half = LandingPlatform.allCases[i].width / 2
            let offset = abs(rocket.position.x - platforms[i].position.x)
            if offset <= half - 23.5 {
                lineColor = SKColor(red: 0.3, green: 1, blue: 0.45, alpha: 1)
                lineAlpha = 0.75
            } else {
                lineColor = .yellow
                lineAlpha = 0.6
            }
        }
        line.color = lineColor
        line.position = CGPoint(x: rocket.position.x, y: feetY)
        line.size = CGSize(width: 1.5, height: max(1, altitude))
        line.alpha = showGuidance ? lineAlpha : 0

        // Readout (text updates every 4 frames to keep label rasterization cheap)
        let rightSide = rocket.position.x < size.width - 120
        label.horizontalAlignmentMode = rightSide ? .left : .right
        label.position = CGPoint(x: rocket.position.x + (rightSide ? 34 : -34), y: rocket.position.y - 6)
        label.alpha = showGuidance ? 1 : 0
        if showGuidance && frameCounter % 4 == 0 {
            let vSpeed = gameState.verticalVelocity
            let platform = pad.map { LandingPlatform.allCases[$0] } ?? .c
            let band = LandingThresholds.verticalBand(vSpeed, platform: platform)
            label.fontColor = band == .safe ? SKColor(red: 0.4, green: 1, blue: 0.5, alpha: 1)
                : band == .hard ? .yellow : SKColor(red: 1, green: 0.35, blue: 0.3, alpha: 1)
            label.text = "\u{2193}\(Int(vSpeed))  ALT \(Int(altitude))"
        }

        // Ground dust kicked up by the plume
        if let dust = dustEmitter {
            let dustRange: CGFloat = 120
            if thrusting && altitude < dustRange {
                dust.position = CGPoint(x: rocket.position.x, y: groundY + 2)
                dust.particleBirthRate = 260 * (1 - altitude / dustRange)
            } else {
                dust.particleBirthRate = 0
            }
        }
    }

    func hideFlightGuidance() {
        guidanceLine?.alpha = 0
        guidanceLabel?.alpha = 0
        dustEmitter?.particleBirthRate = 0
    }

    func makeDustEmitter() -> SKEmitterNode {
        let base: SKColor
        if gameState.currentMode.usesLevelDefinition,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            base = level.terrainStrokeColor
        } else {
            base = SKColor(red: 0.55, green: 0.48, blue: 0.4, alpha: 1)
        }
        let dust = SKEmitterNode()
        dust.particleTexture = StarshipArt.softDot
        dust.particleLifetime = 0.9
        dust.particleLifetimeRange = 0.4
        dust.particleSpeed = 140
        dust.particleSpeedRange = 60
        dust.emissionAngle = .pi / 2
        dust.emissionAngleRange = .pi * 0.85
        dust.yAcceleration = -60
        dust.particlePositionRange = CGVector(dx: 30, dy: 2)
        dust.particleScale = 0.5
        dust.particleScaleRange = 0.2
        dust.particleScaleSpeed = 0.7
        dust.particleAlpha = 0.55
        dust.particleAlphaSpeed = -0.6
        dust.particleColor = base
        dust.particleColorBlendFactor = 1
        dust.zPosition = 9
        return dust
    }

    // MARK: Hazard Callouts

    /// Brief on-screen warning for timed hazards (e.g. Jupiter gusts).
    func showHazardWarning(_ text: String) {
        guard let cam = cameraNode else { return }
        cam.childNode(withName: "hazardWarning")?.removeFromParent()
        let label = SKLabelNode(fontNamed: "Orbitron")
        label.name = "hazardWarning"
        label.text = "\u{26A0} \(text)"
        label.fontSize = 15
        label.fontColor = SKColor(red: 1, green: 0.55, blue: 0.2, alpha: 1)
        label.position = CGPoint(x: 0, y: -size.height * 0.08)
        label.zPosition = 40
        label.alpha = 0
        cam.addChild(label)
        label.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.12),
            SKAction.wait(forDuration: 0.8),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
}

#if DEBUG
// MARK: - Debug Autopilot (CI screenshots / physics smoke test)
extension GameScene {
    /// Simple descent controller: hold attitude upright and keep descent speed
    /// proportional to altitude. Lands on whatever pad is below the start point.
    func runAutopilot() {
        guard hasStarted else {
            gameState.isThrusting = true
            return
        }
        let vy = rocket.physicsBody?.velocity.dy ?? 0
        let targetDescent = max(12, min(90, altitudeAboveSurface() * 0.3))
        gameState.isThrusting = -vy > targetDescent

        let correction = rocket.zRotation + (rocket.physicsBody?.angularVelocity ?? 0) * 0.4
        gameState.isRotatingRight = correction > 0.012
        gameState.isRotatingLeft = correction < -0.012
    }
}
#endif
