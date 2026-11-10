import SpriteKit
import UIKit

// MARK: - Starship Art
// Builds the Starship node, engine plume and shared particle textures.
// Used by the game scene and by the Hangar / menu previews so they always match.

enum StarshipArt {

    // Geometry shared with collision code (see GameScene+Setup.createRocket)
    static let bodyWidth: CGFloat = 26
    static let bodyHeight: CGFloat = 70
    /// Y offset (in ship space) where the engine plume starts.
    static let nozzleExitY: CGFloat = -bodyHeight / 2 - 9
    /// Lowest point of the landing feet.
    static let feetBottomY: CGFloat = -bodyHeight / 2 - 19.25

    // MARK: Textures

    /// Soft radial dot used by every particle effect.
    static let softDot: SKTexture = {
        let size = CGSize(width: 32, height: 32)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let colors = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0).cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) else { return }
            let center = CGPoint(x: 16, y: 16)
            ctx.cgContext.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: 16, options: [])
        }
        return SKTexture(image: image)
    }()

    /// Horizontal cylinder lighting with fine brushed-metal streaks (grayscale, tinted by fillColor).
    static let hullTexture: SKTexture = {
        let size = CGSize(width: 64, height: 128)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let g = ctx.cgContext
            let stops: [(CGFloat, CGFloat)] = [(0, 0.42), (0.12, 0.8), (0.26, 1.0), (0.4, 0.9), (0.68, 0.62), (0.88, 0.42), (1, 0.3)]
            let colors = stops.map { UIColor(white: $0.1, alpha: 1).cgColor } as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: stops.map { $0.0 }) {
                g.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: 0), options: [])
            }
            var rng = SystemRandomNumberGenerator()
            for _ in 0..<70 {
                let x = CGFloat.random(in: 0..<size.width, using: &rng)
                let alpha = CGFloat.random(in: 0.03...0.1, using: &rng)
                g.setFillColor(UIColor(white: Bool.random() ? 1 : 0, alpha: alpha).cgColor)
                g.fill(CGRect(x: x, y: 0, width: 0.6, height: size.height))
            }
        }
        return SKTexture(image: image)
    }()

    /// Soot darkening near the engines (bottom of the hull), transparent above.
    static let sootTexture: SKTexture = {
        let size = CGSize(width: 8, height: 128)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let colors = [UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0).cgColor, UIColor.black.withAlphaComponent(0.5).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.68, 1]) {
                ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
        }
        return SKTexture(image: image)
    }()

    /// Flap depth gradient (lit leading edge to shaded trailing edge).
    static let flapTexture: SKTexture = {
        let size = CGSize(width: 32, height: 32)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let colors = [UIColor(white: 1, alpha: 1).cgColor, UIColor(white: 0.55, alpha: 1).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
                ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            }
        }
        return SKTexture(image: image)
    }()

    /// Sphere shading for planets and moons: lit from the upper left, dark limb and night side.
    static let sphereShade: SKTexture = {
        let size = CGSize(width: 256, height: 256)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let g = ctx.cgContext
            g.addEllipse(in: CGRect(origin: .zero, size: size))
            g.clip()
            let colors = [
                UIColor.white.withAlphaComponent(0.22).cgColor,
                UIColor.black.withAlphaComponent(0).cgColor,
                UIColor.black.withAlphaComponent(0.55).cgColor,
                UIColor.black.withAlphaComponent(0.92).cgColor,
            ] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.3, 0.75, 1]) {
                let light = CGPoint(x: size.width * 0.32, y: size.height * 0.3)
                g.drawRadialGradient(gradient, startCenter: light, startRadius: 0, endCenter: CGPoint(x: size.width * 0.45, y: size.height * 0.45), endRadius: size.width * 0.78, options: [.drawsAfterEndLocation])
            }
        }
        return SKTexture(image: image)
    }()

    /// Shaded boulder (lit top-left), tinted by terrain color.
    static let boulderTexture: SKTexture = {
        let size = CGSize(width: 48, height: 32)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let g = ctx.cgContext
            g.addEllipse(in: CGRect(x: 1, y: 2, width: size.width - 2, height: size.height - 3))
            g.clip()
            let colors = [UIColor(white: 1, alpha: 1).cgColor, UIColor(white: 0.62, alpha: 1).cgColor, UIColor(white: 0.25, alpha: 1).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.45, 1]) {
                g.drawRadialGradient(gradient, startCenter: CGPoint(x: size.width * 0.32, y: size.height * 0.25), startRadius: 0, endCenter: CGPoint(x: size.width * 0.5, y: size.height * 0.5), endRadius: size.width * 0.6, options: [.drawsAfterEndLocation])
            }
        }
        return SKTexture(image: image)
    }()

    /// Procedural ground: lit surface fading to dark rock, strata bands, regolith speckle.
    static func terrainTexture(base: SKColor, width: CGFloat, height: CGFloat) -> SKTexture {
        let size = CGSize(width: max(64, width), height: max(64, height))
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { ctx in
            let g = ctx.cgContext
            let colors = [base.blended(with: .white, fraction: 0.12).cgColor, base.cgColor, base.blended(with: .black, fraction: 0.6).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 0.25, 1]) {
                g.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
            // Strata
            for i in 0..<7 {
                let y0 = size.height * (0.25 + CGFloat(i) * 0.1) + CGFloat.random(in: -6...6)
                let path = CGMutablePath()
                path.move(to: CGPoint(x: 0, y: y0))
                var x: CGFloat = 0
                while x < size.width {
                    x += 24
                    path.addLine(to: CGPoint(x: x, y: y0 + CGFloat.random(in: -3...3)))
                }
                g.addPath(path)
                g.setStrokeColor(UIColor.black.withAlphaComponent(CGFloat.random(in: 0.08...0.18)).cgColor)
                g.setLineWidth(CGFloat.random(in: 1...3))
                g.strokePath()
            }
            // Regolith speckle and pebbles
            let count = Int(size.width * size.height / 70)
            for _ in 0..<count {
                let r = CGFloat.random(in: 0.5...1.8)
                let p = CGPoint(x: CGFloat.random(in: 0..<size.width), y: CGFloat.random(in: 0..<size.height))
                g.setFillColor(UIColor(white: Bool.random() ? 1 : 0, alpha: CGFloat.random(in: 0.05...0.18)).cgColor)
                g.fillEllipse(in: CGRect(x: p.x, y: p.y, width: r * 2, height: r * 2))
            }
            for _ in 0..<Int(size.width / 12) {
                let w = CGFloat.random(in: 3...9)
                let p = CGPoint(x: CGFloat.random(in: 0..<size.width), y: CGFloat.random(in: size.height * 0.15..<size.height))
                g.setFillColor(UIColor.black.withAlphaComponent(0.18).cgColor)
                g.fillEllipse(in: CGRect(x: p.x, y: p.y, width: w, height: w * 0.6))
            }
        }
        return SKTexture(image: image)
    }

    /// Concrete pad with hazard stripes on both ends.
    static let padTexture: SKTexture = {
        let size = CGSize(width: 128, height: 16)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let g = ctx.cgContext
            let colors = [UIColor(white: 0.72, alpha: 1).cgColor, UIColor(white: 0.45, alpha: 1).cgColor] as CFArray
            if let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) {
                g.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
            }
            for x in stride(from: CGFloat(0), to: size.width, by: 16) {
                g.setFillColor(UIColor.black.withAlphaComponent(0.08).cgColor)
                g.fill(CGRect(x: x, y: 0, width: 0.8, height: size.height))
            }
            for end in [CGFloat(0), size.width - 14] {
                for i in 0..<4 {
                    let x = end + CGFloat(i) * 4
                    g.setFillColor((i % 2 == 0 ? UIColor.systemYellow : UIColor.black).cgColor)
                    g.fill(CGRect(x: x, y: 0, width: 4, height: size.height))
                }
            }
        }
        return SKTexture(image: image)
    }()

    /// Vertical gradient texture (top → bottom) for skies.
    static func verticalGradient(top: SKColor, bottom: SKColor, height: Int = 256) -> SKTexture {
        let size = CGSize(width: 4, height: height)
        let image = UIGraphicsImageRenderer(size: size).image { ctx in
            let colors = [top.cgColor, bottom.cgColor] as CFArray
            guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: [0, 1]) else { return }
            ctx.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: 0, y: size.height), options: [])
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }

    // MARK: Ship

    static func makeShip(skin: ShipSkin) -> SKNode {
        let p = skin.palette
        let ship = SKNode()
        let w = bodyWidth
        let h = bodyHeight
        let darkMetal = SKColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1.0)

        // Main body (cylinder with ogive nose)
        let bodyPath = CGMutablePath()
        bodyPath.move(to: CGPoint(x: -w/2, y: -h/2 + 5))
        bodyPath.addLine(to: CGPoint(x: -w/2, y: h/2 - 18))
        bodyPath.addQuadCurve(to: CGPoint(x: w/2, y: h/2 - 18), control: CGPoint(x: 0, y: h/2 + 12))
        bodyPath.addLine(to: CGPoint(x: w/2, y: -h/2 + 5))
        bodyPath.closeSubpath()
        // Hull: cylindrical lighting + brushed-steel streaks, tinted by the livery
        let hull = shape(bodyPath, fill: p.body, stroke: p.stroke, line: 1.2)
        hull.fillTexture = hullTexture
        ship.addChild(hull)

        // Engine soot rising from the skirt
        let soot = shape(bodyPath, fill: .white)
        soot.fillTexture = sootTexture
        ship.addChild(soot)

        // Heat-shield tile strip with seams
        let tilePanel = SKShapeNode(rectOf: CGSize(width: 7, height: 45), cornerRadius: 1.5)
        tilePanel.position = CGPoint(x: w/2 - 4.5, y: -5)
        tilePanel.fillColor = p.heatShield
        tilePanel.strokeColor = SKColor.black.withAlphaComponent(0.35)
        tilePanel.lineWidth = 0.4
        ship.addChild(tilePanel)
        for yPos: CGFloat in stride(from: -23, through: 17, by: 8) {
            ship.addChild(rect(CGSize(width: 6, height: 0.45), at: CGPoint(x: w/2 - 4.5, y: yPos), fill: SKColor.white.withAlphaComponent(0.18)))
        }

        // Nose sheen
        let noseSheen = SKShapeNode(ellipseOf: CGSize(width: 11, height: 6))
        noseSheen.position = CGPoint(x: -3, y: h/2 - 16)
        noseSheen.fillColor = p.highlight.withAlphaComponent(0.35)
        noseSheen.strokeColor = .clear
        ship.addChild(noseSheen)

        // Panel seams
        for yPos: CGFloat in [-22, -8, 8, 22] {
            ship.addChild(rect(CGSize(width: w - 4, height: 0.5), at: CGPoint(x: 0, y: yPos), fill: p.stroke.withAlphaComponent(0.5)))
        }
        ship.addChild(rect(CGSize(width: 0.5, height: h * 0.6), at: CGPoint(x: 0, y: -2), fill: p.shadow))

        // Livery accent stripe
        if let accent = p.accent {
            ship.addChild(rect(CGSize(width: w - 2, height: 2.2), at: CGPoint(x: 0, y: 2), fill: accent))
            ship.addChild(rect(CGSize(width: w - 6, height: 1), at: CGPoint(x: 0, y: -1.5), fill: accent.withAlphaComponent(0.6)))
        }

        // Forward flaps
        for offset in [-1, 1] {
            let s = CGFloat(offset)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: s * w/2, y: 16))
            path.addLine(to: CGPoint(x: s * (w/2 + 16), y: 13))
            path.addLine(to: CGPoint(x: s * (w/2 + 12), y: 30))
            path.addLine(to: CGPoint(x: s * w/2, y: 28))
            path.closeSubpath()
            addFlap(path, to: ship, palette: p, hingeX: s * w/2, hingeY: 23, hingeHeight: 12)
        }

        // Aft flaps
        for offset in [-1, 1] {
            let s = CGFloat(offset)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: s * w/2, y: -12))
            path.addLine(to: CGPoint(x: s * (w/2 + 18), y: -10))
            path.addLine(to: CGPoint(x: s * (w/2 + 14), y: -28))
            path.addLine(to: CGPoint(x: s * w/2, y: -25))
            path.closeSubpath()
            addFlap(path, to: ship, palette: p, hingeX: s * w/2, hingeY: -20, hingeHeight: 14)
        }

        // Engine skirt
        let enginePath = CGMutablePath()
        enginePath.move(to: CGPoint(x: -w/2, y: -h/2 + 5))
        enginePath.addLine(to: CGPoint(x: -w/2 - 3, y: -h/2 - 8))
        enginePath.addLine(to: CGPoint(x: w/2 + 3, y: -h/2 - 8))
        enginePath.addLine(to: CGPoint(x: w/2, y: -h/2 + 5))
        enginePath.closeSubpath()
        ship.addChild(shape(enginePath, fill: darkMetal, stroke: p.stroke.withAlphaComponent(0.6), line: 1))
        ship.addChild(rect(CGSize(width: w + 9, height: 1.5), at: CGPoint(x: 0, y: -h/2 + 3), fill: SKColor(red: 0.58, green: 0.59, blue: 0.62, alpha: 0.9), corner: 0.75))

        // Three Raptor nozzles
        for i in -1...1 {
            let nx = CGFloat(i) * 8
            let ny = -h/2 - 5
            let nozzlePath = CGMutablePath()
            nozzlePath.move(to: CGPoint(x: nx - 3, y: ny + 3))
            nozzlePath.addLine(to: CGPoint(x: nx - 4, y: ny - 4))
            nozzlePath.addLine(to: CGPoint(x: nx + 4, y: ny - 4))
            nozzlePath.addLine(to: CGPoint(x: nx + 3, y: ny + 3))
            nozzlePath.closeSubpath()
            ship.addChild(shape(nozzlePath, fill: SKColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 1), stroke: darkMetal, line: 0.5))
        }

        // Landing legs + feet, each on a hinge node so they can fold against the hull
        for offset in [-1, 1] {
            let s = CGFloat(offset)
            let hinge = CGPoint(x: s * 10, y: -h/2 + 3)
            let leg = SKNode()
            leg.name = legNodeName
            leg.position = hinge
            leg.userData = ["side": s]
            let legPath = CGMutablePath()
            legPath.move(to: CGPoint(x: s * 8 - hinge.x, y: -h/2 + 2 - hinge.y))
            legPath.addLine(to: CGPoint(x: s * 22 - hinge.x, y: -h/2 - 18 - hinge.y))
            legPath.addLine(to: CGPoint(x: s * 25 - hinge.x, y: -h/2 - 17 - hinge.y))
            legPath.addLine(to: CGPoint(x: s * 12 - hinge.x, y: -h/2 + 4 - hinge.y))
            legPath.closeSubpath()
            leg.addChild(shape(legPath, fill: SKColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1), stroke: p.stroke.withAlphaComponent(0.6), line: 1))
            leg.addChild(rect(CGSize(width: 8, height: 2.5), at: CGPoint(x: s * 23.5 - hinge.x, y: -h/2 - 18 - hinge.y), fill: SKColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1), corner: 1))
            ship.addChild(leg)
        }

        return ship
    }

    // MARK: Landing legs

    static let legNodeName = "landingLeg"
    /// Folded angle magnitude (legs swing up along the hull, ~137°).
    static let legStowedAngle: CGFloat = 2.4

    /// Folds (deployed = false) or extends the landing legs.
    static func setLegs(of ship: SKNode, deployed: Bool, animated: Bool) {
        ship.enumerateChildNodes(withName: legNodeName) { node, _ in
            let side = (node.userData?["side"] as? CGFloat) ?? 1
            let target = deployed ? 0 : side * legStowedAngle
            if animated {
                let swing = SKAction.rotate(toAngle: target, duration: 0.45, shortestUnitArc: false)
                swing.timingMode = .easeOut
                node.run(swing)
            } else {
                node.zRotation = target
            }
        }
    }

    // MARK: Engine

    /// Main-engine plume. Starts idle (birth rate 0); call `setThrottle` to fire.
    static func makeEnginePlume(skin: ShipSkin) -> SKEmitterNode {
        let p = skin.palette
        let e = SKEmitterNode()
        e.particleTexture = softDot
        e.particleBirthRate = 0
        e.particleLifetime = 0.34
        e.particleLifetimeRange = 0.12
        e.particlePositionRange = CGVector(dx: 16, dy: 2)
        e.emissionAngle = -.pi / 2
        e.emissionAngleRange = 0.2
        e.particleSpeed = 210
        e.particleSpeedRange = 60
        e.particleAlpha = 0.95
        e.particleAlphaSpeed = -2.4
        e.particleScale = 0.6
        e.particleScaleRange = 0.18
        e.particleScaleSpeed = -1.1
        e.particleBlendMode = .add
        e.particleColorBlendFactor = 1
        e.particleColorSequence = SKKeyframeSequence(
            keyframeValues: [p.flameCore, p.flameOuter, p.flameOuter.withAlphaComponent(0.4), SKColor(white: 0.4, alpha: 0)],
            times: [0, 0.25, 0.65, 1]
        )
        e.position = CGPoint(x: 0, y: nozzleExitY)
        e.zPosition = -1
        return e
    }

    /// Engine bell glow sprite (additive), shown while thrusting.
    static func makeEngineGlow(skin: ShipSkin) -> SKSpriteNode {
        let glow = SKSpriteNode(texture: softDot)
        glow.size = CGSize(width: 46, height: 30)
        glow.color = skin.palette.flameOuter
        glow.colorBlendFactor = 1
        glow.blendMode = .add
        glow.alpha = 0
        glow.position = CGPoint(x: 0, y: nozzleExitY - 4)
        glow.zPosition = -1

        // Shock diamonds (Mach disks) in the exhaust core
        for (i, y) in [CGFloat(-16), -30, -43].enumerated() {
            let diamond = SKSpriteNode(texture: softDot)
            diamond.size = CGSize(width: 12 - CGFloat(i) * 2.5, height: 9 - CGFloat(i) * 1.5)
            diamond.color = skin.palette.flameCore
            diamond.colorBlendFactor = 1
            diamond.blendMode = .add
            diamond.alpha = 0.9 - CGFloat(i) * 0.22
            diamond.position = CGPoint(x: 0, y: y)
            glow.addChild(diamond)
        }
        return glow
    }

    // MARK: Helpers

    private static func shape(_ path: CGPath, fill: SKColor, stroke: SKColor = .clear, line: CGFloat = 0) -> SKShapeNode {
        let node = SKShapeNode(path: path)
        node.fillColor = fill
        node.strokeColor = stroke
        node.lineWidth = line
        return node
    }

    private static func rect(_ size: CGSize, at position: CGPoint, fill: SKColor, corner: CGFloat = 0) -> SKShapeNode {
        let node = SKShapeNode(rectOf: size, cornerRadius: corner)
        node.position = position
        node.fillColor = fill
        node.strokeColor = .clear
        return node
    }

    private static func addFlap(_ path: CGPath, to ship: SKNode, palette p: ShipSkin.Palette, hingeX: CGFloat, hingeY: CGFloat, hingeHeight: CGFloat) {
        let flap = shape(path, fill: p.flap, stroke: p.stroke.withAlphaComponent(0.7), line: 1)
        flap.fillTexture = flapTexture
        ship.addChild(flap)
        let bevel = shape(path, fill: .clear, stroke: p.flapHighlight, line: 0.6)
        bevel.alpha = 0.75
        ship.addChild(bevel)
        ship.addChild(rect(CGSize(width: 2, height: hingeHeight), at: CGPoint(x: hingeX, y: hingeY), fill: p.stroke.withAlphaComponent(0.7)))
    }
}

// MARK: - Ship Preview Scene (Hangar / Menu)

final class ShipPreviewScene: SKScene {
    private let skin: ShipSkin
    private let showsFlame: Bool

    init(skin: ShipSkin, size: CGSize, showsFlame: Bool = true) {
        self.skin = skin
        self.showsFlame = showsFlame
        super.init(size: size)
        backgroundColor = .clear
        scaleMode = .aspectFit
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        removeAllChildren()
        let ship = StarshipArt.makeShip(skin: skin)
        let shipHeight: CGFloat = 112
        let scale = min(size.width / 70, size.height / (shipHeight + (showsFlame ? 50 : 0)))
        ship.setScale(scale)
        ship.position = CGPoint(x: size.width / 2, y: size.height * (showsFlame ? 0.62 : 0.52))
        addChild(ship)

        if showsFlame {
            let plume = StarshipArt.makeEnginePlume(skin: skin)
            plume.particleBirthRate = 260
            plume.particleSpeed = 120
            ship.addChild(plume)
            let glow = StarshipArt.makeEngineGlow(skin: skin)
            glow.alpha = 0.8
            ship.addChild(glow)
        }

        let hover = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 4, duration: 1.4),
            SKAction.moveBy(x: 0, y: -4, duration: 1.4),
        ])
        hover.timingMode = .easeInEaseOut
        ship.run(.repeatForever(hover))
    }
}

// MARK: - Color Helpers

extension SKColor {
    private var rgba: (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) { return (r, g, b, a) }
        var white: CGFloat = 0
        getWhite(&white, alpha: &a)
        return (white, white, white, a)
    }

    /// Perceived brightness 0...1.
    var luminance: CGFloat {
        let c = rgba
        return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b
    }

    /// Linear blend toward `other` (fraction 0 = self, 1 = other).
    func blended(with other: SKColor, fraction: CGFloat) -> SKColor {
        let a = rgba, b = other.rgba
        let t = max(0, min(1, fraction))
        return SKColor(
            red: a.r + (b.r - a.r) * t,
            green: a.g + (b.g - a.g) * t,
            blue: a.b + (b.b - a.b) * t,
            alpha: a.a + (b.a - a.a) * t
        )
    }
}
