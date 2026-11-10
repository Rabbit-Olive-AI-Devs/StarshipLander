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
        ship.addChild(shape(bodyPath, fill: p.body, stroke: p.stroke, line: 1.5))

        // Left-side reflection
        let highlightPath = CGMutablePath()
        highlightPath.move(to: CGPoint(x: -w/2 + 3, y: -h/2 + 8))
        highlightPath.addLine(to: CGPoint(x: -w/2 + 3, y: h/2 - 20))
        highlightPath.addLine(to: CGPoint(x: -w/2 + 7, y: h/2 - 22))
        highlightPath.addLine(to: CGPoint(x: -w/2 + 7, y: -h/2 + 8))
        highlightPath.closeSubpath()
        ship.addChild(shape(highlightPath, fill: p.highlight))

        // Right-side shadow
        let shadowPath = CGMutablePath()
        shadowPath.move(to: CGPoint(x: w/2 - 5, y: -h/2 + 7))
        shadowPath.addLine(to: CGPoint(x: w/2 - 2, y: h/2 - 20))
        shadowPath.addLine(to: CGPoint(x: w/2, y: h/2 - 18))
        shadowPath.addLine(to: CGPoint(x: w/2, y: -h/2 + 6))
        shadowPath.closeSubpath()
        ship.addChild(shape(shadowPath, fill: p.shadow))

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
        noseSheen.fillColor = SKColor.white.withAlphaComponent(0.22)
        noseSheen.strokeColor = .clear
        ship.addChild(noseSheen)

        // Panel seams
        for yPos: CGFloat in [-22, -8, 8, 22] {
            ship.addChild(rect(CGSize(width: w - 4, height: 0.5), at: CGPoint(x: 0, y: yPos), fill: p.stroke.withAlphaComponent(0.5)))
        }
        ship.addChild(rect(CGSize(width: 0.5, height: h * 0.6), at: CGPoint(x: 0, y: -2), fill: p.stroke.withAlphaComponent(0.3)))

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

        // Landing legs + feet
        for offset in [-1, 1] {
            let s = CGFloat(offset)
            let legPath = CGMutablePath()
            legPath.move(to: CGPoint(x: s * 8, y: -h/2 + 2))
            legPath.addLine(to: CGPoint(x: s * 22, y: -h/2 - 18))
            legPath.addLine(to: CGPoint(x: s * 25, y: -h/2 - 17))
            legPath.addLine(to: CGPoint(x: s * 12, y: -h/2 + 4))
            legPath.closeSubpath()
            ship.addChild(shape(legPath, fill: SKColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1), stroke: p.stroke.withAlphaComponent(0.6), line: 1))
            ship.addChild(rect(CGSize(width: 8, height: 2.5), at: CGPoint(x: s * 23.5, y: -h/2 - 18), fill: SKColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 1), corner: 1))
        }

        return ship
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
        ship.addChild(shape(path, fill: p.flap, stroke: p.stroke.withAlphaComponent(0.7), line: 1))
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
