import SpriteKit
import UIKit

// MARK: - Starship Art
// Builds the Starship node, engine plume and shared particle textures.
// Used by the game scene and by the Hangar / menu previews so they always match.

enum StarshipArt {

    // Geometry shared with collision code (see GameScene+Setup.createRocket).
    // The art is rendered by Scripts/render_art.py in these same ship-space points.
    /// Y offset (in ship space) where the engine plume starts (Raptor bell exits).
    static let nozzleExitY: CGFloat = -44
    /// Lowest point of the landing feet.
    static let feetBottomY: CGFloat = -54.25
    /// Body sprite extents in ship-space points (matches SHIP_X / SHIP_Y in render_art.py).
    private static let bodyRect = CGRect(x: -30, y: -46, width: 60, height: 90)
    /// Leg sprite extents relative to its hinge (LEG_X / LEG_Y in render_art.py).
    private static let legRect = CGRect(x: -3, y: -25, width: 24, height: 28)
    private static let legHinge = CGPoint(x: 7, y: -31)

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
        let ship = SKNode()

        // Landing legs on hinge nodes (behind the hull) so they can fold
        let legTexture = texture(named: "ship_leg")
        for side in [CGFloat(-1), CGFloat(1)] {
            let hinge = SKNode()
            hinge.name = legNodeName
            hinge.position = CGPoint(x: side * legHinge.x, y: legHinge.y)
            hinge.userData = ["side": side]
            hinge.zPosition = -0.5
            let leg = SKSpriteNode(texture: legTexture, size: legRect.size)
            leg.anchorPoint = CGPoint(x: -legRect.minX / legRect.width, y: -legRect.minY / legRect.height)
            leg.xScale = side
            hinge.addChild(leg)
            ship.addChild(hinge)
        }

        let body = SKSpriteNode(texture: texture(named: "ship_\(skin.rawValue)"), size: bodyRect.size)
        body.anchorPoint = CGPoint(x: -bodyRect.minX / bodyRect.width, y: -bodyRect.minY / bodyRect.height)
        ship.addChild(body)
        return ship
    }

    /// Cached, mipmapped texture from the asset catalog.
    static func texture(named name: String) -> SKTexture {
        if let cached = textureCache[name] { return cached }
        let texture = SKTexture(imageNamed: name)
        texture.usesMipmaps = true
        texture.filteringMode = .linear
        textureCache[name] = texture
        return texture
    }

    private static var textureCache: [String: SKTexture] = [:]

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
        e.particlePositionRange = CGVector(dx: 12, dy: 2)
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
        glow.size = CGSize(width: 34, height: 24)
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
