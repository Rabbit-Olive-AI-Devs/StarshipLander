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
        let skyLuminance = skyColors.bottom.luminance
        let visibility = max(0.12, 1.0 - skyLuminance * 2.2)

        for layer in 0..<3 {
            let starCount = 30 + layer * 20
            let alpha = (0.3 + Double(layer) * 0.25) * Double(visibility)

            for _ in 0..<starCount {
                let star = SKSpriteNode(texture: StarshipArt.softDot)
                let diameter = CGFloat.random(in: 2.0...(4.0 + CGFloat(layer) * 1.5))
                star.size = CGSize(width: diameter, height: diameter)
                star.alpha = CGFloat(alpha * Double.random(in: 0.5...1.0))
                star.position = CGPoint(
                    x: CGFloat.random(in: 0...size.width),
                    y: CGFloat.random(in: size.height * 0.3...size.height)
                )
                star.zPosition = -20 + CGFloat(layer)

                let twinkle = SKAction.sequence([
                    SKAction.fadeAlpha(to: CGFloat(alpha * 0.3), duration: Double.random(in: 0.5...2.0)),
                    SKAction.fadeAlpha(to: CGFloat(alpha), duration: Double.random(in: 0.5...2.0))
                ])
                star.run(SKAction.repeatForever(twinkle))

                addChild(star)
            }
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

    func createCelestialBody() {
        let celestial: CelestialBody
        let posX: CGFloat
        let posY: CGFloat
        var planetName = "Moon"

        if gameState.currentMode.usesLevelDefinition,
           let level = LevelDefinition.level(for: gameState.currentLevelId) {
            celestial = level.celestialBody
            planetName = level.name
            posX = size.width * 0.8
            posY = size.height * 0.75
        } else {
            celestial = .moon
            posX = size.width * 0.8
            posY = size.height * 0.75
        }

        let r = celestial.radius

        // Base sphere
        let body = SKShapeNode(circleOfRadius: r)
        body.fillColor = celestial.color
        body.strokeColor = .clear
        body.position = CGPoint(x: posX, y: posY)
        body.zPosition = -5

        // Craters (Moon, Mercury, Ganymede)
        for _ in 0..<celestial.craterCount {
            let craterR = CGFloat.random(in: 3...8)
            let crater = SKShapeNode(circleOfRadius: craterR)
            crater.fillColor = celestial.color.withAlphaComponent(0.6)
            crater.strokeColor = celestial.color.withAlphaComponent(0.4)
            crater.lineWidth = 0.5
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.7)
            crater.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            body.addChild(crater)

            // Inner shadow for depth
            let inner = SKShapeNode(circleOfRadius: craterR * 0.6)
            inner.fillColor = celestial.color.withAlphaComponent(0.45)
            inner.strokeColor = .clear
            inner.position = CGPoint(x: craterR * 0.15, y: -craterR * 0.15)
            crater.addChild(inner)
        }

        // Planet-specific surface features
        switch celestial.name {
        case "Earth":
            addEarthFeatures(to: body, radius: r)
        case "Jupiter":
            addJupiterBands(to: body, radius: r)
        case "Saturn":
            addSaturnFeatures(to: body, radius: r, hasRings: celestial.hasRings)
        case "Sun":
            addSunFeatures(to: body, radius: r)
        case "Moon":
            break // craters are enough
        case "Europa":
            addEuropaFeatures(to: body, radius: r)
        default:
            break
        }

        // Level-specific surface overlays
        switch planetName {
        case "Europa":
            addEuropaFeatures(to: body, radius: r)
        case "Titan":
            break // Saturn parent handled above
        case "Ganymede", "Io":
            if planetName == "Io" {
                addIoFeatures(to: body, radius: r)
            }
        default:
            break
        }

        // Atmospheric glow for planets with atmosphere
        let hasAtmosphere = ["Earth", "Mars", "Venus", "Saturn"].contains(celestial.name)
            || ["Titan", "Jupiter", "Io"].contains(planetName)
        if hasAtmosphere {
            let glow = SKShapeNode(circleOfRadius: r + 3)
            glow.fillColor = .clear
            glow.strokeColor = celestial.color.withAlphaComponent(0.25)
            glow.lineWidth = 4
            glow.glowWidth = 6
            body.addChild(glow)
        }

        // Terminator shadow (dark edge for 3D effect)
        let shadowPath = CGMutablePath()
        shadowPath.addArc(center: .zero, radius: r, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: false)
        shadowPath.addLine(to: CGPoint(x: r * 0.3, y: -r))
        shadowPath.closeSubpath()
        let shadow = SKShapeNode(path: shadowPath)
        shadow.fillColor = SKColor.black.withAlphaComponent(0.2)
        shadow.strokeColor = .clear
        shadow.zPosition = 2
        body.addChild(shadow)

        // Rings for Saturn/Titan
        if celestial.hasRings {
            // Back ring (behind planet)
            let backRing = SKShapeNode(ellipseOf: CGSize(width: r * 3.2, height: r * 0.7))
            backRing.strokeColor = SKColor(red: 0.8, green: 0.7, blue: 0.5, alpha: 0.25)
            backRing.lineWidth = 5
            backRing.fillColor = .clear
            backRing.zPosition = -1
            body.addChild(backRing)

            // Front ring
            let frontRing = SKShapeNode(ellipseOf: CGSize(width: r * 3, height: r * 0.6))
            frontRing.strokeColor = SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.4)
            frontRing.lineWidth = 4
            frontRing.fillColor = .clear
            frontRing.zPosition = 3
            body.addChild(frontRing)

            let innerRing = SKShapeNode(ellipseOf: CGSize(width: r * 2.5, height: r * 0.5))
            innerRing.strokeColor = SKColor(red: 0.7, green: 0.6, blue: 0.4, alpha: 0.3)
            innerRing.lineWidth = 3
            innerRing.fillColor = .clear
            innerRing.zPosition = 3
            body.addChild(innerRing)
        }

        addChild(body)
    }

    // MARK: - Planet Surface Features

    private func addEarthFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Continents as irregular blobs
        let continentColor = SKColor(red: 0.2, green: 0.55, blue: 0.2, alpha: 0.7)
        let continents: [(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat)] = [
            (-0.25, 0.3, 0.35, 0.25),   // North America
            (-0.15, -0.1, 0.2, 0.3),     // South America
            (0.15, 0.25, 0.25, 0.35),    // Europe/Africa
            (0.35, 0.15, 0.25, 0.2),     // Asia
            (0.3, -0.25, 0.2, 0.15),     // Australia
        ]

        for c in continents {
            let path = CGMutablePath()
            let cx = c.x * r
            let cy = c.y * r
            let w = c.w * r
            let h = c.h * r
            path.addEllipse(in: CGRect(x: cx - w/2, y: cy - h/2, width: w, height: h))
            let continent = SKShapeNode(path: path)
            continent.fillColor = continentColor
            continent.strokeColor = SKColor(red: 0.15, green: 0.4, blue: 0.15, alpha: 0.5)
            continent.lineWidth = 0.5
            continent.zPosition = 1
            body.addChild(continent)
        }

        // Polar ice caps
        for ySign: CGFloat in [-1, 1] {
            let cap = SKShapeNode(ellipseOf: CGSize(width: r * 0.8, height: r * 0.2))
            cap.fillColor = SKColor.white.withAlphaComponent(0.5)
            cap.strokeColor = .clear
            cap.position = CGPoint(x: 0, y: ySign * r * 0.8)
            cap.zPosition = 1
            body.addChild(cap)
        }

        // Cloud wisps
        for _ in 0..<4 {
            let cloud = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: r * 0.3...r * 0.6),
                height: CGFloat.random(in: r * 0.06...r * 0.12)
            ))
            cloud.fillColor = SKColor.white.withAlphaComponent(0.2)
            cloud.strokeColor = .clear
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.6)
            cloud.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            cloud.zPosition = 1.5
            body.addChild(cloud)
        }
    }

    private func addMarsFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Darker regions (maria)
        let darkColor = SKColor(red: 0.55, green: 0.2, blue: 0.12, alpha: 0.4)
        for _ in 0..<5 {
            let patch = SKShapeNode(ellipseOf: CGSize(
                width: CGFloat.random(in: r * 0.2...r * 0.5),
                height: CGFloat.random(in: r * 0.15...r * 0.35)
            ))
            patch.fillColor = darkColor
            patch.strokeColor = .clear
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.5)
            patch.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            patch.zPosition = 1
            body.addChild(patch)
        }

        // Polar cap
        let cap = SKShapeNode(ellipseOf: CGSize(width: r * 0.5, height: r * 0.15))
        cap.fillColor = SKColor.white.withAlphaComponent(0.4)
        cap.strokeColor = .clear
        cap.position = CGPoint(x: 0, y: r * 0.75)
        cap.zPosition = 1
        body.addChild(cap)

        // Olympus Mons hint
        let volcano = SKShapeNode(circleOfRadius: r * 0.1)
        volcano.fillColor = SKColor(red: 0.7, green: 0.25, blue: 0.15, alpha: 0.5)
        volcano.strokeColor = SKColor(red: 0.5, green: 0.15, blue: 0.1, alpha: 0.3)
        volcano.lineWidth = 1
        volcano.position = CGPoint(x: -r * 0.3, y: r * 0.2)
        volcano.zPosition = 1
        body.addChild(volcano)
    }

    private func addJupiterBands(to body: SKShapeNode, radius r: CGFloat) {
        let bandColors: [SKColor] = [
            SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.3),
            SKColor(red: 0.7, green: 0.55, blue: 0.35, alpha: 0.35),
            SKColor(red: 0.9, green: 0.8, blue: 0.6, alpha: 0.25),
            SKColor(red: 0.65, green: 0.5, blue: 0.3, alpha: 0.3),
            SKColor(red: 0.85, green: 0.7, blue: 0.5, alpha: 0.2),
        ]

        for (i, color) in bandColors.enumerated() {
            let yPos = r * (-0.6 + CGFloat(i) * 0.3)
            let bandHeight = r * CGFloat.random(in: 0.1...0.18)
            let halfWidth = sqrt(max(0, r * r - yPos * yPos))

            let band = SKShapeNode(rectOf: CGSize(width: halfWidth * 2, height: bandHeight))
            band.fillColor = color
            band.strokeColor = .clear
            band.position = CGPoint(x: 0, y: yPos)
            band.zPosition = 1
            body.addChild(band)
        }

        // Great Red Spot
        let spot = SKShapeNode(ellipseOf: CGSize(width: r * 0.25, height: r * 0.15))
        spot.fillColor = SKColor(red: 0.8, green: 0.35, blue: 0.2, alpha: 0.5)
        spot.strokeColor = SKColor(red: 0.7, green: 0.3, blue: 0.15, alpha: 0.3)
        spot.lineWidth = 1
        spot.position = CGPoint(x: r * 0.2, y: -r * 0.2)
        spot.zPosition = 1.5
        body.addChild(spot)
    }

    private func addVenusFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Thick cloud bands
        for i in 0..<4 {
            let yPos = r * (-0.4 + CGFloat(i) * 0.25)
            let cloud = SKShapeNode(ellipseOf: CGSize(
                width: r * CGFloat.random(in: 1.2...1.6),
                height: r * CGFloat.random(in: 0.12...0.2)
            ))
            cloud.fillColor = SKColor(red: 0.95, green: 0.8, blue: 0.5, alpha: 0.15)
            cloud.strokeColor = .clear
            cloud.position = CGPoint(x: CGFloat.random(in: -r * 0.2...r * 0.2), y: yPos)
            cloud.zPosition = 1
            body.addChild(cloud)
        }
    }

    private func addSaturnFeatures(to body: SKShapeNode, radius r: CGFloat, hasRings: Bool) {
        // Subtle bands
        for i in 0..<3 {
            let yPos = r * (-0.3 + CGFloat(i) * 0.3)
            let band = SKShapeNode(ellipseOf: CGSize(width: r * 1.5, height: r * 0.12))
            band.fillColor = SKColor(red: 0.85, green: 0.75, blue: 0.55, alpha: 0.15)
            band.strokeColor = .clear
            band.position = CGPoint(x: 0, y: yPos)
            band.zPosition = 1
            body.addChild(band)
        }
    }

    private func addSunFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Bright inner glow
        let innerGlow = SKShapeNode(circleOfRadius: r * 0.85)
        innerGlow.fillColor = SKColor(red: 1.0, green: 0.98, blue: 0.85, alpha: 0.7)
        innerGlow.strokeColor = .clear
        innerGlow.zPosition = 1
        body.addChild(innerGlow)

        // Outer corona glow
        let corona = SKShapeNode(circleOfRadius: r + 12)
        corona.fillColor = .clear
        corona.strokeColor = SKColor(red: 1.0, green: 0.9, blue: 0.4, alpha: 0.4)
        corona.lineWidth = 8
        corona.glowWidth = 15
        corona.zPosition = -1
        body.addChild(corona)

        // Subtle "sunspot" darker regions
        for _ in 0..<2 {
            let spot = SKShapeNode(circleOfRadius: CGFloat.random(in: r * 0.05...r * 0.1))
            spot.fillColor = SKColor(red: 0.95, green: 0.8, blue: 0.4, alpha: 0.5)
            spot.strokeColor = .clear
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.5)
            spot.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            spot.zPosition = 2
            body.addChild(spot)
        }
    }

    private func addEuropaFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Ice cracks
        let crackColor = SKColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 0.4)
        for _ in 0..<8 {
            let path = CGMutablePath()
            let startAngle = CGFloat.random(in: 0...(.pi * 2))
            let startDist = CGFloat.random(in: r * 0.1...r * 0.5)
            var x = cos(startAngle) * startDist
            var y = sin(startAngle) * startDist
            path.move(to: CGPoint(x: x, y: y))

            for _ in 0..<3 {
                x += CGFloat.random(in: -r * 0.3...r * 0.3)
                y += CGFloat.random(in: -r * 0.3...r * 0.3)
                path.addLine(to: CGPoint(x: x, y: y))
            }

            let crack = SKShapeNode(path: path)
            crack.strokeColor = crackColor
            crack.lineWidth = 0.8
            crack.zPosition = 1
            body.addChild(crack)
        }
    }

    private func addIoFeatures(to body: SKShapeNode, radius r: CGFloat) {
        // Volcanic spots
        let colors: [SKColor] = [
            SKColor(red: 0.9, green: 0.8, blue: 0.1, alpha: 0.5),
            SKColor(red: 0.85, green: 0.5, blue: 0.1, alpha: 0.5),
            SKColor(red: 0.7, green: 0.3, blue: 0.1, alpha: 0.4),
        ]
        for _ in 0..<6 {
            let spotR = CGFloat.random(in: r * 0.05...r * 0.12)
            let spot = SKShapeNode(circleOfRadius: spotR)
            spot.fillColor = colors.randomElement()!
            spot.strokeColor = .clear
            let angle = CGFloat.random(in: 0...(.pi * 2))
            let dist = CGFloat.random(in: 0...r * 0.65)
            spot.position = CGPoint(x: cos(angle) * dist, y: sin(angle) * dist)
            spot.zPosition = 1
            body.addChild(spot)
        }
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
        terrain.fillColor = fillColor
        terrain.strokeColor = strokeColor
        terrain.lineWidth = 2
        terrain.zPosition = 1

        // Texture rocks
        for _ in 0..<30 {
            let rock = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            rock.fillColor = fillColor.withAlphaComponent(0.5)
            rock.strokeColor = .clear
            rock.position = CGPoint(
                x: CGFloat.random(in: 20...size.width - 20),
                y: CGFloat.random(in: 100...200)
            )
            terrain.addChild(rock)
        }

        addChild(terrain)

        // Solid terrain on every world — touching it is a crash, not a fall-through
        addTerrainPhysics(heights: heights, segmentWidth: segmentWidth)

        // Ganymede (deep craters): rock pillars between platforms
        if gameState.currentMode.usesLevelDefinition && gameState.currentLevelId == 8 {
            addGanymedeRocks()
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
            platformNode.fillColor = SKColor(red: 0.3, green: 0.3, blue: 0.35, alpha: 1.0)
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
