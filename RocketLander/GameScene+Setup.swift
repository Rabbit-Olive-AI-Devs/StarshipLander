import SpriteKit

// MARK: - Scene Setup
extension GameScene {

    // MARK: - Sky

    /// Per-planet sky color pair (classic mode uses the deep-space default).
    var skyColors: (top: SKColor, bottom: SKColor) {
        if gameState.currentMode.usesLevelDefinition,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            return (level.skyColorTop, level.skyColorBottom)
        }
        return (SKColor(red: 0.0, green: 0.0, blue: 0.03, alpha: 1), SKColor(red: 0.05, green: 0.05, blue: 0.15, alpha: 1))
    }

    func createSky() {
        let colors = skyColors
        let sky = SKSpriteNode(texture: StarshipArt.verticalGradient(top: colors.top, bottom: colors.bottom))
        sky.size = size
        sky.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sky.zPosition = -30
        addChild(sky)

        // Horizon glow — atmosphere scattering above the terrain line
        let glow = SKSpriteNode(texture: StarshipArt.softDot)
        glow.size = CGSize(width: size.width * 1.8, height: 260)
        glow.position = CGPoint(x: size.width / 2, y: 230)
        glow.color = colors.bottom.blended(with: .white, fraction: 0.35)
        glow.colorBlendFactor = 1
        glow.blendMode = .add
        glow.alpha = 0.35
        glow.zPosition = -12
        addChild(glow)
    }

    func createStarfield() {
        // Fewer, dimmer stars under bright atmospheres (Venus, Titan, Mars)
        let visibility = max(0.08, 1.0 - skyColors.bottom.luminance * 2.4)

        // Rendered deep-space starfield with the Milky Way, added over the sky gradient
        let field = SKSpriteNode(texture: StarshipArt.texture(named: "sky_stars"))
        let fieldAspect: CGFloat = 0.5
        let height = max(size.height, size.width / fieldAspect)
        field.size = CGSize(width: height * fieldAspect, height: height)
        field.position = CGPoint(x: size.width / 2, y: size.height - height / 2)
        field.blendMode = .add
        field.alpha = visibility
        field.zPosition = -21
        addChild(field)

        // A few bright stars that twinkle on top of the static field
        for _ in 0..<22 {
            let star = SKSpriteNode(texture: StarshipArt.softDot)
            let diameter = CGFloat.random(in: 3...6)
            star.size = CGSize(width: diameter, height: diameter)
            let peak = CGFloat.random(in: 0.5...0.95) * visibility
            star.alpha = peak
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: size.height * 0.35...size.height)
            )
            star.zPosition = -19
            star.run(SKAction.repeatForever(SKAction.sequence([
                SKAction.fadeAlpha(to: peak * 0.3, duration: Double.random(in: 0.6...2.0)),
                SKAction.fadeAlpha(to: peak, duration: Double.random(in: 0.6...2.0))
            ])))
            addChild(star)
        }

        // Occasional shooting star on dark skies
        guard visibility > 0.6 else { return }
        let meteor = SKAction.sequence([
            SKAction.wait(forDuration: 4, withRange: 6),
            SKAction.run { [weak self] in self?.spawnShootingStar() }
        ])
        run(SKAction.repeatForever(meteor), withKey: "shootingStars")
    }

    private func spawnShootingStar() {
        let streak = SKSpriteNode(color: .white, size: CGSize(width: 60, height: 1.5))
        streak.alpha = 0
        streak.zPosition = -9
        let startX = CGFloat.random(in: size.width * 0.2...size.width)
        let startY = CGFloat.random(in: size.height * 0.65...size.height * 0.95)
        streak.position = CGPoint(x: startX, y: startY)
        streak.zRotation = .pi * 0.88
        addChild(streak)
        let travel = SKAction.moveBy(x: -220, y: -70, duration: 0.7)
        let fade = SKAction.sequence([SKAction.fadeAlpha(to: 0.8, duration: 0.1), SKAction.wait(forDuration: 0.35), SKAction.fadeOut(withDuration: 0.25)])
        streak.run(SKAction.sequence([SKAction.group([travel, fade]), SKAction.removeFromParent()]))
    }

    /// Rendered planet/moon/Sun (Scripts/render_art.py) seen in the sky.
    func createCelestialBody() {
        let celestial: CelestialBody = activeLevel?.celestialBody ?? .moon
        let r = celestial.radius
        let body = SKSpriteNode(texture: StarshipArt.texture(named: "planet_\(celestial.name.lowercased())"))
        switch celestial.name {
        case "Saturn":
            // Rendered at 1536×768 with the planet radius = 0.3 × image height
            let h = r / 0.3
            body.size = CGSize(width: h * 2, height: h)
        case "Sun":
            // Disk fills 42% of the image; the rest is corona
            body.size = CGSize(width: 2 * r / 0.42, height: 2 * r / 0.42)
        default:
            // Disk fills 82% of the image; the rest is atmosphere glow
            body.size = CGSize(width: 2 * r / 0.82, height: 2 * r / 0.82)
        }
        body.position = CGPoint(x: size.width * 0.8, y: size.height * 0.75)
        body.zPosition = -5
        addChild(body)
    }

    /// Hazy background ridge for depth. Decorative only (no physics).
    func createDistantRidge() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        var heights: [CGFloat] = []
        var x: CGFloat = 0
        while x <= size.width + 40 {
            heights.append(CGFloat.random(in: 205...285))
            x += 40
        }
        for _ in 0..<2 {
            for i in 1..<max(2, heights.count - 1) {
                heights[i] = (heights[i - 1] + heights[i] * 2 + heights[i + 1]) / 4
            }
        }
        for (i, h) in heights.enumerated() {
            path.addLine(to: CGPoint(x: CGFloat(i) * 40, y: h))
        }
        path.addLine(to: CGPoint(x: CGFloat(heights.count - 1) * 40, y: 0))
        path.closeSubpath()

        let base = gameState.currentMode.usesLevelDefinition
            ? (LevelDefinition.level(for: gameState.currentLevelId)?.terrainColor ?? .gray)
            : SKColor(red: 0.25, green: 0.2, blue: 0.15, alpha: 1.0)
        let ridge = SKShapeNode(path: path)
        ridge.fillColor = base.blended(with: skyColors.bottom, fraction: 0.6)
        ridge.strokeColor = .clear
        ridge.zPosition = -8
        addChild(ridge)
    }

    func createTerrain() {
        let terrainPath = CGMutablePath()
        terrainPath.move(to: CGPoint(x: 0, y: 0))

        let segmentWidth = terrainSegmentWidth
        var heights: [CGFloat] = []
        var x: CGFloat = 0

        // Get platform positions to create valleys
        let platformPositions = LandingPlatform.allCases.map { $0.xFraction * size.width }
        let platformWidths = LandingPlatform.allCases.map { $0.width }

        while x <= size.width {
            var baseHeight: CGFloat = 180 + CGFloat.random(in: -20...40)

            // Create valleys near platform positions
            for (i, platX) in platformPositions.enumerated() {
                let halfWidth = platformWidths[i] / 2 + 30 // Extra margin
                let dist = abs(x - platX)
                if dist < halfWidth {
                    // Create a valley — lower the terrain near platforms
                    let valleyDepth: CGFloat = 60
                    let valleyFactor = 1.0 - (dist / halfWidth)
                    baseHeight -= valleyDepth * valleyFactor
                }
            }

            // Deep craters for Ganymede: raise terrain at screen edges
            // (Rock pillars between platforms are added separately in addGanymedeRocks)
            if gameState.currentMode.usesLevelDefinition && gameState.currentLevelId == 8 {
                let leftWallEnd: CGFloat = 40
                let rightWallStart: CGFloat = size.width - 50
                let wallHeight: CGFloat = 350
                let valleyHeight: CGFloat = 150

                if x < leftWallEnd {
                    let ramp = 1.0 - (x / leftWallEnd)
                    baseHeight = valleyHeight + (wallHeight - valleyHeight) * ramp + CGFloat.random(in: -5...5)
                } else if x > rightWallStart {
                    let ramp = (x - rightWallStart) / (size.width - rightWallStart)
                    baseHeight = valleyHeight + (wallHeight - valleyHeight) * ramp + CGFloat.random(in: -5...5)
                } else {
                    baseHeight = valleyHeight + CGFloat.random(in: -8...8)
                }
            }

            heights.append(baseHeight)
            x += segmentWidth
        }

        // Smooth heights
        for i in 1..<heights.count - 1 {
            heights[i] = (heights[i-1] + heights[i] + heights[i+1]) / 3
        }

        terrainHeights = heights

        // Draw terrain
        x = 0
        for height in heights {
            terrainPath.addLine(to: CGPoint(x: x, y: height))
            x += segmentWidth
        }

        terrainPath.addLine(to: CGPoint(x: size.width, y: 0))
        terrainPath.closeSubpath()

        // Determine terrain colors
        let fillColor: SKColor
        let strokeColor: SKColor

        if gameState.currentMode.usesLevelDefinition,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            fillColor = level.terrainColor
            strokeColor = level.terrainStrokeColor
        } else {
            fillColor = SKColor(red: 0.25, green: 0.2, blue: 0.15, alpha: 1.0)
            strokeColor = SKColor(red: 0.35, green: 0.3, blue: 0.25, alpha: 1.0)
        }

        terrain = SKShapeNode(path: terrainPath)
        // Rendered regolith/rock detail (Scripts/render_art.py), tinted per world
        terrain.fillTexture = StarshipArt.texture(named: "ground_detail")
        terrain.fillColor = fillColor.blended(with: .white, fraction: 0.3)
        terrain.strokeColor = strokeColor
        terrain.lineWidth = 1.5
        terrain.zPosition = 1

        addBoulders(heights: heights, segmentWidth: segmentWidth, tint: fillColor)

        addChild(terrain)

        // Solid terrain on every world — touching it is a crash, not a fall-through
        addTerrainPhysics(heights: heights, segmentWidth: segmentWidth)

        // Ganymede (deep craters): rock pillars between platforms
        if gameState.currentMode.usesLevelDefinition && gameState.currentLevelId == 8 {
            addGanymedeRocks()
        }
    }

    /// Shaded boulders resting on the surface, kept clear of the pads.
    private func addBoulders(heights: [CGFloat], segmentWidth: CGFloat, tint: SKColor) {
        let padRanges = LandingPlatform.allCases.map { pad -> ClosedRange<CGFloat> in
            let x = pad.xFraction * size.width
            return (x - pad.width / 2 - 12)...(x + pad.width / 2 + 12)
        }
        var placed = 0
        var attempts = 0
        while placed < 16 && attempts < 80 {
            attempts += 1
            let x = CGFloat.random(in: 8...(size.width - 8))
            guard !padRanges.contains(where: { $0.contains(x) }) else { continue }
            let i = min(heights.count - 1, Int(x / segmentWidth))
            let width = CGFloat.random(in: 7...20)
            let boulder = SKSpriteNode(texture: StarshipArt.boulderTexture)
            boulder.size = CGSize(width: width, height: width * CGFloat.random(in: 0.55...0.75))
            boulder.color = tint.blended(with: .white, fraction: 0.15)
            boulder.colorBlendFactor = 1
            boulder.position = CGPoint(x: x, y: heights[i] + boulder.size.height * 0.2)
            boulder.zPosition = 1.5
            addChild(boulder)
            placed += 1
        }
    }

    private func addTerrainPhysics(heights: [CGFloat], segmentWidth: CGFloat) {
        // Build an edge-chain physics body along the terrain surface
        var points: [CGPoint] = []
        for (i, h) in heights.enumerated() {
            points.append(CGPoint(x: CGFloat(i) * segmentWidth, y: h))
        }
        // Close along the bottom
        points.append(CGPoint(x: CGFloat(heights.count - 1) * segmentWidth, y: 0))
        points.append(CGPoint(x: 0, y: 0))

        let terrainBody = SKPhysicsBody(edgeChainFrom: {
            let path = CGMutablePath()
            path.move(to: points[0])
            for i in 1..<points.count {
                path.addLine(to: points[i])
            }
            path.closeSubpath()
            return path
        }())
        terrainBody.categoryBitMask = groundCategory
        terrainBody.contactTestBitMask = rocketCategory
        terrainBody.friction = 0.5
        terrain.physicsBody = terrainBody
    }

    private func addGanymedeRocks() {
        // Place rock pillars between platforms to create crater hazards
        // Platform edges: A right ~135, B left ~141, B right ~251, C left ~282
        // Gap between B and C: ~251 to ~282 (30pt) — place a pillar here
        // Also place pillars at screen edges for visual crater walls

        let rockColor = SKColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        let rockStroke = SKColor(red: 0.45, green: 0.4, blue: 0.35, alpha: 1.0)

        struct RockDef {
            let x: CGFloat
            let width: CGFloat
            let height: CGFloat
        }

        let platB_right = LandingPlatform.allCases[1].xFraction * size.width + LandingPlatform.allCases[1].width / 2
        let platC_left = LandingPlatform.allCases[2].xFraction * size.width - LandingPlatform.allCases[2].width / 2
        let midBC = (platB_right + platC_left) / 2

        let rocks: [RockDef] = [
            // Central pillar between B and C
            RockDef(x: midBC, width: 18, height: 180),
            // Left screen edge pillar
            RockDef(x: 15, width: 25, height: 200),
            // Right screen edge pillar
            RockDef(x: size.width - 18, width: 22, height: 190),
        ]

        for rock in rocks {
            // Jagged rock shape
            let path = CGMutablePath()
            let hw = rock.width / 2
            path.move(to: CGPoint(x: -hw, y: 0))
            path.addLine(to: CGPoint(x: -hw * 0.8, y: rock.height * 0.4))
            path.addLine(to: CGPoint(x: -hw * 1.1, y: rock.height * 0.6))
            path.addLine(to: CGPoint(x: -hw * 0.5, y: rock.height * 0.8))
            path.addLine(to: CGPoint(x: 0, y: rock.height))
            path.addLine(to: CGPoint(x: hw * 0.6, y: rock.height * 0.85))
            path.addLine(to: CGPoint(x: hw * 1.1, y: rock.height * 0.55))
            path.addLine(to: CGPoint(x: hw * 0.7, y: rock.height * 0.3))
            path.addLine(to: CGPoint(x: hw, y: 0))
            path.closeSubpath()

            let rockNode = SKShapeNode(path: path)
            rockNode.fillColor = rockColor
            rockNode.strokeColor = rockStroke
            rockNode.lineWidth = 1.5
            rockNode.position = CGPoint(x: rock.x, y: 150)  // sits on terrain
            rockNode.zPosition = 3

            // Physics body — hitting the rock = crash
            rockNode.physicsBody = SKPhysicsBody(polygonFrom: path)
            rockNode.physicsBody?.isDynamic = false
            rockNode.physicsBody?.categoryBitMask = groundCategory
            rockNode.physicsBody?.contactTestBitMask = rocketCategory
            rockNode.physicsBody?.friction = 0.5

            addChild(rockNode)
        }
    }

    func createGround() {
        ground = SKShapeNode(rectOf: CGSize(width: size.width * 2, height: 10))
        ground.position = CGPoint(x: size.width / 2, y: 5)
        ground.fillColor = SKColor(red: 0.2, green: 0.15, blue: 0.1, alpha: 1.0)
        ground.strokeColor = .clear
        ground.zPosition = 2

        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 10))
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = groundCategory
        ground.physicsBody?.contactTestBitMask = rocketCategory
        ground.physicsBody?.friction = 0.5

        addChild(ground)
    }

    func createPlatforms() {
        platforms = []

        for platformDef in LandingPlatform.allCases {
            let platformWidth = platformDef.width
            let platformHeight: CGFloat = 8
            let platformX = platformDef.xFraction * size.width

            let platformNode = SKShapeNode(rectOf: CGSize(width: platformWidth, height: platformHeight), cornerRadius: 2)
            platformNode.position = CGPoint(x: platformX, y: 220 + platformHeight / 2)
            platformNode.fillColor = SKColor(red: 0.85, green: 0.85, blue: 0.88, alpha: 1.0)
            platformNode.fillTexture = StarshipArt.padTexture
            platformNode.strokeColor = SKColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1.0)
            platformNode.lineWidth = 2
            platformNode.zPosition = 3
            platformNode.name = "platform_\(platformDef.rawValue)"

            platformNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: platformWidth, height: platformHeight))
            platformNode.physicsBody?.isDynamic = false
            platformNode.physicsBody?.categoryBitMask = platformCategory
            platformNode.physicsBody?.contactTestBitMask = rocketCategory

            // Low friction for Europa (icy world)
            if gameState.currentMode.usesLevelDefinition && gameState.currentLevelId == 4 {
                platformNode.physicsBody?.friction = 0.05
            } else {
                platformNode.physicsBody?.friction = 0.8
            }

            // Platform legs
            for offset in [-1, 1] {
                let leg = SKShapeNode(rectOf: CGSize(width: 6, height: 20))
                leg.fillColor = SKColor(red: 0.25, green: 0.25, blue: 0.3, alpha: 1.0)
                leg.strokeColor = .clear
                leg.position = CGPoint(x: CGFloat(offset) * (platformWidth / 2 - 15), y: -14)
                platformNode.addChild(leg)
            }

            // Floodlight pool on the ground beneath the pad
            let pool = SKSpriteNode(texture: StarshipArt.softDot)
            pool.size = CGSize(width: platformWidth * 1.4, height: 30)
            pool.color = platformDef.lightColor
            pool.colorBlendFactor = 1
            pool.blendMode = .add
            pool.alpha = 0.22
            pool.position = CGPoint(x: 0, y: -26)
            pool.zPosition = -2
            platformNode.addChild(pool)

            // Landing marking
            let marking = SKShapeNode(rectOf: CGSize(width: platformWidth - 20, height: 2))
            marking.fillColor = platformDef.lightColor
            marking.strokeColor = .clear
            marking.position = CGPoint(x: 0, y: 0)
            platformNode.addChild(marking)

            // Landing lights
            let lightColor = platformDef.lightColor
            for offset in [-1, 1] {
                let light = SKShapeNode(circleOfRadius: 4)
                light.position = CGPoint(x: CGFloat(offset) * (platformWidth / 2 - 8), y: platformHeight / 2 + 4)
                light.fillColor = lightColor
                light.strokeColor = .clear
                light.zPosition = 1

                let glow = SKShapeNode(circleOfRadius: 8)
                glow.fillColor = lightColor.withAlphaComponent(0.3)
                glow.strokeColor = .clear
                glow.zPosition = -1
                light.addChild(glow)

                let pulse = SKAction.sequence([
                    SKAction.fadeAlpha(to: 0.5, duration: 0.5),
                    SKAction.fadeAlpha(to: 1.0, duration: 0.5)
                ])
                light.run(SKAction.repeatForever(pulse))

                platformNode.addChild(light)
            }

            // Platform label below
            let label = SKLabelNode(text: "\(platformDef.label)")
            label.fontSize = 10
            label.fontName = "Orbitron"
            label.fontColor = platformDef.lightColor
            label.position = CGPoint(x: 0, y: -32)
            platformNode.addChild(label)

            let multiplierLabel = SKLabelNode(text: "\(Int(platformDef.multiplier))x")
            multiplierLabel.fontSize = 12
            multiplierLabel.fontName = "Orbitron"
            multiplierLabel.fontColor = SKColor.white
            multiplierLabel.position = CGPoint(x: 0, y: -44)
            platformNode.addChild(multiplierLabel)

            addChild(platformNode)
            platforms.append(platformNode)
        }
    }

    func createRocket() {
        rocket = StarshipArt.makeShip(skin: shipSkin)
        rocket.zPosition = 10

        let plume = StarshipArt.makeEnginePlume(skin: shipSkin)
        plume.targetNode = self
        rocket.addChild(plume)
        enginePlume = plume

        let glow = StarshipArt.makeEngineGlow(skin: shipSkin)
        rocket.addChild(glow)
        engineGlow = glow
        isEngineLit = false

        // Position rocket — upper-left for multi-platform layout
        rocket.position = CGPoint(x: size.width * 0.15, y: size.height - 100)

        // Physics body covers hull + landing legs so the feet touch the pad
        let bodyTop: CGFloat = 42
        let bodyBottom = StarshipArt.feetBottomY
        rocket.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(width: 54, height: bodyTop - bodyBottom),
            center: CGPoint(x: 0, y: (bodyTop + bodyBottom) / 2)
        )
        rocket.physicsBody?.mass = 1.0
        rocket.physicsBody?.linearDamping = 0.0
        rocket.physicsBody?.angularDamping = GameScene.freeAngularDamping
        rocket.physicsBody?.allowsRotation = true
        rocket.physicsBody?.categoryBitMask = rocketCategory
        rocket.physicsBody?.contactTestBitMask = platformCategory | groundCategory
        rocket.physicsBody?.collisionBitMask = platformCategory | groundCategory
        rocket.physicsBody?.isDynamic = false
        rocket.physicsBody?.restitution = 0.0
        rocket.physicsBody?.friction = 0.5
        rocket.physicsBody?.affectedByGravity = true

        addChild(rocket)
    }
}
