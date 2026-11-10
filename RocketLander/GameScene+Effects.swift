import SpriteKit

enum WindIntensity {
    case light, heavy, extreme
}

// MARK: - Visual Effects
extension GameScene {

    // MARK: - Engine

    /// Lights or cuts the main engine plume. Cheap to call every frame.
    func setEngine(on: Bool) {
        guard on != isEngineLit else { return }
        isEngineLit = on
        enginePlume?.particleBirthRate = on ? 520 : 0
        engineGlow?.removeAllActions()
        if on {
            let flicker = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.95, duration: 0.05),
                SKAction.fadeAlpha(to: 0.7, duration: 0.07)
            ])
            engineGlow?.run(SKAction.repeatForever(flicker))
        } else {
            engineGlow?.run(SKAction.fadeOut(withDuration: 0.12))
        }
    }

    // MARK: - Touchdown

    func createTouchdownEffect(platform: LandingPlatform, speedBand: SpeedBand) {
        let feet = CGPoint(x: rocket.position.x, y: rocket.position.y + StarshipArt.feetBottomY)

        // Dust skirt kicked out sideways
        let dust = makeDustEmitter()
        dust.position = feet
        dust.particleBirthRate = 900
        dust.numParticlesToEmit = 70
        dust.particleSpeed = 110
        dust.emissionAngle = .pi / 2
        dust.emissionAngleRange = .pi * 0.9
        addChild(dust)
        dust.run(SKAction.sequence([SKAction.wait(forDuration: 1.6), SKAction.removeFromParent()]))

        // Pad lights celebrate
        if let index = LandingPlatform.allCases.firstIndex(of: platform), index < platforms.count {
            let pad = platforms[index]
            let ring = SKShapeNode(ellipseOf: CGSize(width: platform.width, height: 14))
            ring.position = CGPoint(x: pad.position.x, y: pad.position.y + 4)
            ring.strokeColor = platform.lightColor
            ring.lineWidth = 2
            ring.glowWidth = 3
            ring.zPosition = 4
            addChild(ring)
            ring.run(SKAction.sequence([
                SKAction.group([SKAction.scale(to: 2.2, duration: 0.6), SKAction.fadeOut(withDuration: 0.6)]),
                SKAction.removeFromParent()
            ]))
        }

        // Celebration sparks rising off the ship
        let sparks = SKEmitterNode()
        sparks.particleTexture = StarshipArt.softDot
        sparks.particleBirthRate = 260
        sparks.numParticlesToEmit = speedBand == .safe ? 90 : 40
        sparks.particleLifetime = 1.4
        sparks.particleSpeed = 150
        sparks.particleSpeedRange = 80
        sparks.emissionAngle = .pi / 2
        sparks.emissionAngleRange = 1.2
        sparks.yAcceleration = -120
        sparks.particleScale = 0.25
        sparks.particleScaleRange = 0.15
        sparks.particleAlphaSpeed = -0.6
        sparks.particleBlendMode = .add
        sparks.particleColorBlendFactor = 1
        sparks.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [SKColor.white, SKColor(red: 1, green: 0.82, blue: 0.45, alpha: 1), SKColor(red: 1, green: 0.55, blue: 0.2, alpha: 1)],
            times: [0, 0.4, 1]
        )
        sparks.position = CGPoint(x: rocket.position.x, y: rocket.position.y + 20)
        sparks.zPosition = 20
        addChild(sparks)
        sparks.run(SKAction.sequence([SKAction.wait(forDuration: 2.0), SKAction.removeFromParent()]))

        // Suspension bump on the ship and a small camera dip
        let squash = SKAction.sequence([
            SKAction.scaleY(to: 0.94, duration: 0.07),
            SKAction.scaleY(to: 1.0, duration: 0.18)
        ])
        rocket.run(squash)
        shakeCamera(intensity: speedBand == .safe ? 2 : 5, duration: 0.18)
    }

    // MARK: - Explosion

    func createExplosion(at position: CGPoint) {
        // Flash
        let flash = SKSpriteNode(color: .white, size: CGSize(width: size.width * 2, height: size.height * 2))
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 50
        flash.alpha = 0.55
        flash.blendMode = .add
        addChild(flash)
        flash.run(SKAction.sequence([SKAction.fadeOut(withDuration: 0.25), SKAction.removeFromParent()]))

        // Shockwave
        let wave = SKShapeNode(circleOfRadius: 12)
        wave.position = position
        wave.strokeColor = SKColor(red: 1, green: 0.8, blue: 0.5, alpha: 0.9)
        wave.fillColor = .clear
        wave.lineWidth = 3
        wave.glowWidth = 4
        wave.zPosition = 21
        addChild(wave)
        wave.run(SKAction.sequence([
            SKAction.group([SKAction.scale(to: 9, duration: 0.45), SKAction.fadeOut(withDuration: 0.45)]),
            SKAction.removeFromParent()
        ]))

        // Fireball
        let fire = SKEmitterNode()
        fire.particleTexture = StarshipArt.softDot
        fire.particleBirthRate = 2400
        fire.numParticlesToEmit = 160
        fire.particleLifetime = 0.75
        fire.particleLifetimeRange = 0.3
        fire.particleSpeed = 190
        fire.particleSpeedRange = 140
        fire.emissionAngleRange = .pi * 2
        fire.particleScale = 1.1
        fire.particleScaleRange = 0.5
        fire.particleScaleSpeed = -0.9
        fire.particleAlphaSpeed = -1.2
        fire.particleBlendMode = .add
        fire.particleColorBlendFactor = 1
        fire.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [SKColor.white, SKColor(red: 1, green: 0.8, blue: 0.3, alpha: 1), SKColor(red: 1, green: 0.35, blue: 0.05, alpha: 1), SKColor(red: 0.3, green: 0.05, blue: 0.0, alpha: 1)],
            times: [0, 0.15, 0.5, 1]
        )
        fire.position = position
        fire.zPosition = 20
        addChild(fire)
        fire.run(SKAction.sequence([SKAction.wait(forDuration: 1.4), SKAction.removeFromParent()]))

        // Rising smoke
        let smoke = SKEmitterNode()
        smoke.particleTexture = StarshipArt.softDot
        smoke.particleBirthRate = 90
        smoke.numParticlesToEmit = 60
        smoke.particleLifetime = 2.2
        smoke.particleSpeed = 40
        smoke.particleSpeedRange = 30
        smoke.emissionAngle = .pi / 2
        smoke.emissionAngleRange = 1.4
        smoke.yAcceleration = 25
        smoke.particleScale = 1.0
        smoke.particleScaleSpeed = 0.9
        smoke.particleAlpha = 0.5
        smoke.particleAlphaSpeed = -0.22
        smoke.particleColor = SKColor(white: 0.18, alpha: 1)
        smoke.particleColorBlendFactor = 1
        smoke.particlePositionRange = CGVector(dx: 20, dy: 10)
        smoke.position = position
        smoke.zPosition = 19
        addChild(smoke)
        smoke.run(SKAction.sequence([SKAction.wait(forDuration: 3.2), SKAction.removeFromParent()]))

        // Hull debris tumbling out (uses the ship's paint)
        let palette = shipSkin.palette
        for _ in 0..<14 {
            let debris = SKShapeNode(rectOf: CGSize(
                width: CGFloat.random(in: 3...11),
                height: CGFloat.random(in: 2...8)
            ))
            debris.fillColor = [palette.body, palette.flap, palette.heatShield, palette.stroke].randomElement() ?? .gray
            debris.strokeColor = .clear
            debris.position = position
            debris.zPosition = 19
            debris.zRotation = CGFloat.random(in: 0...(2 * .pi))
            addChild(debris)

            let angle = CGFloat.random(in: 0.15...(.pi - 0.15))
            let distance = CGFloat.random(in: 50...150)
            let rise = SKAction.moveBy(x: cos(angle) * distance, y: sin(angle) * distance, duration: 0.6)
            rise.timingMode = .easeOut
            let fall = SKAction.moveBy(x: cos(angle) * 30, y: -160, duration: 0.8)
            fall.timingMode = .easeIn
            let spin = SKAction.rotate(byAngle: CGFloat.random(in: -8...8), duration: 1.4)
            let fade = SKAction.sequence([SKAction.wait(forDuration: 0.9), SKAction.fadeOut(withDuration: 0.5)])
            debris.run(SKAction.sequence([SKAction.group([SKAction.sequence([rise, fall]), spin, fade]), SKAction.removeFromParent()]))
        }

        shakeCamera(intensity: 14, duration: 0.45)
    }

    // MARK: - Wind Particles (Mars, Venus, Jupiter)
    func createWindParticles(intensity: WindIntensity) {
        let key = "windParticles"
        removeAction(forKey: key)

        let (count, speed, alpha, color): (Int, CGFloat, CGFloat, SKColor) = {
            switch intensity {
            case .light:  return (1, 120, 0.3, SKColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0))  // Mars dust
            case .heavy:  return (2, 200, 0.4, SKColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0))  // Venus haze
            case .extreme: return (3, 350, 0.5, SKColor.white)                                          // Jupiter streaks
            }
        }()

        // Venus (heavy): vertical particles; others: horizontal
        let isVertical = (intensity == .heavy)

        let spawn = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                for _ in 0..<count {
                    let streakSize: CGSize
                    let startPos: CGPoint
                    let moveAction: SKAction

                    if isVertical {
                        // Vertical streaks for Venus updrafts
                        streakSize = CGSize(
                            width: CGFloat.random(in: 1...2),
                            height: CGFloat.random(in: 15...40)
                        )
                        startPos = CGPoint(
                            x: CGFloat.random(in: 50...self.size.width - 50),
                            y: -20
                        )
                        moveAction = SKAction.moveBy(
                            x: CGFloat.random(in: -30...30),
                            y: self.size.height + 60,
                            duration: Double(self.size.height / speed)
                        )
                    } else {
                        // Horizontal streaks for Mars (right→left) and Jupiter (left→right)
                        let isJupiter = (intensity == .extreme)
                        streakSize = CGSize(
                            width: CGFloat.random(in: 15...40),
                            height: CGFloat.random(in: 1...2)
                        )
                        if isJupiter {
                            // Jupiter: particles blow left→right (matching wind direction)
                            startPos = CGPoint(
                                x: -20,
                                y: CGFloat.random(in: 100...self.size.height - 50)
                            )
                            moveAction = SKAction.moveBy(
                                x: self.size.width + 60,
                                y: CGFloat.random(in: -30...30),
                                duration: Double(self.size.width / speed)
                            )
                        } else {
                            // Mars: particles blow right→left
                            startPos = CGPoint(
                                x: self.size.width + 20,
                                y: CGFloat.random(in: 100...self.size.height - 50)
                            )
                            moveAction = SKAction.moveBy(
                                x: -(self.size.width + 60),
                                y: CGFloat.random(in: -30...30),
                                duration: Double(self.size.width / speed)
                            )
                        }
                    }

                    let streak = SKShapeNode(rectOf: streakSize)
                    streak.fillColor = color.withAlphaComponent(alpha)
                    streak.strokeColor = .clear
                    streak.position = startPos
                    streak.zPosition = 5
                    self.addChild(streak)

                    streak.run(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
                }
            },
            SKAction.wait(forDuration: Double.random(in: 0.15...0.4))
        ])
        run(SKAction.repeatForever(spawn), withKey: key)
    }

    // MARK: - Atmosphere Haze (Titan)
    func createAtmosphereHaze() {
        // Semi-transparent orange gradient overlay at top of screen
        let haze = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height * 0.4))
        haze.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        haze.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 0.15)
        haze.strokeColor = .clear
        haze.zPosition = 4
        haze.name = "atmosphereHaze"
        addChild(haze)

        // Drifting haze particles
        let spawn = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let cloud = SKShapeNode(ellipseOf: CGSize(
                    width: CGFloat.random(in: 60...120),
                    height: CGFloat.random(in: 15...30)
                ))
                cloud.fillColor = SKColor(red: 0.5, green: 0.4, blue: 0.2, alpha: 0.08)
                cloud.strokeColor = .clear
                cloud.position = CGPoint(
                    x: self.size.width + 60,
                    y: CGFloat.random(in: self.size.height * 0.4...self.size.height)
                )
                cloud.zPosition = 4
                self.addChild(cloud)

                let drift = SKAction.moveBy(x: -(self.size.width + 150), y: 0, duration: Double.random(in: 8...14))
                cloud.run(SKAction.sequence([drift, SKAction.removeFromParent()]))
            },
            SKAction.wait(forDuration: Double.random(in: 1.5...3.0))
        ])
        run(SKAction.repeatForever(spawn), withKey: "atmosphereHaze")
    }

    // MARK: - Ice Shimmer (Europa)
    func createIceShimmer() {
        // Periodic sparkle particles on the lower portion of screen (near platforms)
        let sparkle = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                for _ in 0..<3 {
                    let spark = SKShapeNode(circleOfRadius: CGFloat.random(in: 1...3))
                    spark.fillColor = SKColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 0.8)
                    spark.strokeColor = .clear
                    spark.position = CGPoint(
                        x: CGFloat.random(in: 20...self.size.width - 20),
                        y: CGFloat.random(in: 160...240)
                    )
                    spark.zPosition = 6
                    self.addChild(spark)

                    let twinkle = SKAction.sequence([
                        SKAction.fadeIn(withDuration: 0.2),
                        SKAction.wait(forDuration: Double.random(in: 0.1...0.3)),
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.removeFromParent()
                    ])
                    spark.run(twinkle)
                }
            },
            SKAction.wait(forDuration: Double.random(in: 0.3...0.8))
        ])
        run(SKAction.repeatForever(sparkle), withKey: "iceShimmer")
    }

    // MARK: - Cryogeyser Effect (Europa)
    func createCryogeyserEffect() {
        let spawn = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                for i in 0..<self.geyserPositions.count {
                    guard i < self.geyserActive.count, self.geyserActive[i] else { continue }
                    let gx = self.geyserPositions[i]
                    let baseY: CGFloat = 180

                    // Spawn 3-5 particles per tick per active geyser
                    let particleCount = Int.random(in: 3...5)
                    for _ in 0..<particleCount {
                        let radius = CGFloat.random(in: 2...5)
                        let particle = SKShapeNode(circleOfRadius: radius)
                        let colors: [SKColor] = [
                            SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 0.8),  // light blue
                            SKColor(red: 0.85, green: 0.9, blue: 1.0, alpha: 0.75), // white-blue
                            SKColor(red: 0.5, green: 0.9, blue: 0.95, alpha: 0.7)   // cyan
                        ]
                        particle.fillColor = colors.randomElement()!
                        particle.strokeColor = .clear
                        particle.position = CGPoint(
                            x: gx + CGFloat.random(in: -8...8),
                            y: baseY
                        )
                        particle.zPosition = 15
                        self.addChild(particle)

                        // Vertical column trajectory
                        let dy = CGFloat.random(in: 150...300)
                        let dx = CGFloat.random(in: -5...5)
                        let duration = Double.random(in: 0.5...1.0)

                        let move = SKAction.moveBy(x: dx, y: dy, duration: duration)
                        let fade = SKAction.fadeOut(withDuration: duration)
                        let scale = SKAction.scale(to: 0.3, duration: duration)
                        let group = SKAction.group([move, fade, scale])
                        particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
                    }
                }
            },
            SKAction.wait(forDuration: 0.15)
        ])
        run(SKAction.repeatForever(spawn), withKey: "cryogeysers")
    }

    // MARK: - Heat Shimmer Effect (Mercury)
    func createHeatShimmer() {
        guard gameState.currentMode.usesLevelDefinition && gameState.currentLevelId == 7 else { return }

        // Visible heat shimmer — wobbles the rocket noticeably
        let shimmer = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self, let rocket = self.rocket else { return }
                // More pronounced visual wobble
                let dx = CGFloat.random(in: -3.0...3.0)
                let dy = CGFloat.random(in: -1.5...1.5)
                let distort = SKAction.sequence([
                    SKAction.moveBy(x: dx, y: dy, duration: 0.08),
                    SKAction.moveBy(x: -dx, y: -dy, duration: 0.08)
                ])
                rocket.run(distort)
            },
            SKAction.wait(forDuration: 0.15)
        ])
        run(SKAction.repeatForever(shimmer), withKey: "heatShimmer")

        // Also add rising heat distortion particles
        let heatParticles = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                for _ in 0..<2 {
                    let particle = SKShapeNode(ellipseOf: CGSize(
                        width: CGFloat.random(in: 30...60),
                        height: CGFloat.random(in: 8...15)
                    ))
                    particle.fillColor = SKColor(red: 1.0, green: 0.9, blue: 0.7, alpha: 0.08)
                    particle.strokeColor = .clear
                    particle.position = CGPoint(
                        x: CGFloat.random(in: 30...self.size.width - 30),
                        y: CGFloat.random(in: 150...250)
                    )
                    particle.zPosition = 4
                    self.addChild(particle)

                    let rise = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: 150, duration: 2.0)
                    let wobble = SKAction.sequence([
                        SKAction.moveBy(x: 5, y: 0, duration: 0.3),
                        SKAction.moveBy(x: -10, y: 0, duration: 0.3),
                        SKAction.moveBy(x: 5, y: 0, duration: 0.3)
                    ])
                    let fade = SKAction.fadeOut(withDuration: 2.0)
                    let group = SKAction.group([rise, SKAction.repeatForever(wobble), fade])
                    particle.run(SKAction.sequence([group, SKAction.removeFromParent()]))
                }
            },
            SKAction.wait(forDuration: 0.5)
        ])
        run(SKAction.repeatForever(heatParticles), withKey: "heatParticles")
    }

    // MARK: - Volcanic Eruptions (Io)
    func createVolcanicEruption() {
        guard gameState.currentMode.usesLevelDefinition && gameState.currentLevelId == 9 else { return }

        let erupt = SKAction.sequence([
            SKAction.wait(forDuration: Double.random(in: 2.0...5.0)),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                let eruptX = CGFloat.random(in: 50...self.size.width - 50)
                let eruptY: CGFloat = 180

                for _ in 0..<8 {
                    let radius = CGFloat.random(in: 3...7)
                    let particle = SKShapeNode(circleOfRadius: radius)
                    particle.fillColor = [SKColor.orange, SKColor.red, SKColor.yellow].randomElement()!
                    particle.strokeColor = .clear
                    particle.position = CGPoint(x: eruptX, y: eruptY)
                    particle.zPosition = 15

                    // Deadly volcanic debris — collides with rocket
                    particle.physicsBody = SKPhysicsBody(circleOfRadius: radius)
                    particle.physicsBody?.isDynamic = false
                    particle.physicsBody?.categoryBitMask = self.groundCategory
                    particle.physicsBody?.contactTestBitMask = self.rocketCategory

                    self.addChild(particle)

                    let dx = CGFloat.random(in: -40...40)
                    let dy = CGFloat.random(in: 80...200)

                    let move = SKAction.moveBy(x: dx, y: dy, duration: Double.random(in: 0.6...1.2))
                    let removePhysics = SKAction.run { particle.physicsBody = nil }
                    let fall = SKAction.moveBy(x: 0, y: -dy * 1.5, duration: 0.8)
                    let fade = SKAction.fadeOut(withDuration: 0.5)
                    let seq = SKAction.sequence([move, removePhysics, SKAction.group([fall, fade]), SKAction.removeFromParent()])
                    particle.run(seq)
                }
            }
        ])
        run(SKAction.repeatForever(erupt), withKey: "volcanicEruption")
    }
}
