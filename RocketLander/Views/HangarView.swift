import SwiftUI

// MARK: - Hangar
// Browse, unlock (Pilot Rank or Blue Stars) and equip Starship paint schemes.

struct HangarView: View {
    @Binding var showingHangar: Bool
    @ObservedObject var hangar: HangarManager
    @ObservedObject var blueStars: BlueStarManager
    @ObservedObject var progress: PilotProgress
    @State private var focused: ShipSkin = HangarManager.shared.selectedSkin
    @State private var showingPurchaseError = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 12) {
            header

            ScrollView {
                VStack(spacing: 16) {
                    preview
                    actionButton
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(ShipSkin.allCases) { skin in
                            skinCard(skin)
                        }
                    }
                    Text("Earn Blue Stars from Daily Challenges, streaks, campaign milestones and Pilot Rank promotions.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .padding(.top)
        .alert(isPresented: $showingPurchaseError) {
            Alert(title: Text("Not enough Blue Stars"), message: Text("Complete Daily Challenges and rank up to earn more."), dismissButton: .default(Text("OK")))
        }
    }

    // MARK: Sections

    private var header: some View {
        HStack {
            Button(action: { showingHangar = false }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            Spacer()
            Text("HANGAR")
                .font(.custom("Orbitron", size: 20).weight(.bold))
                .foregroundColor(.white)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.cyan)
                Text("\(blueStars.blueStars)")
                    .font(.custom("Orbitron", size: 14).weight(.bold))
                    .foregroundColor(.cyan)
            }
        }
        .padding(.horizontal)
    }

    private var preview: some View {
        VStack(spacing: 6) {
            ShipPreviewView(skin: focused)
                .frame(height: 210)
            Text(focused.displayName.uppercased())
                .font(.custom("Orbitron", size: 18).weight(.black))
                .foregroundColor(.white)
            Text(focused.tagline)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RadialGradient(colors: [Color(focused.palette.flameOuter).opacity(0.25), .clear], center: .bottom, startRadius: 10, endRadius: 220)
        )
        .background(Color.white.opacity(0.04))
        .cornerRadius(16)
    }

    @ViewBuilder
    private var actionButton: some View {
        let availability = hangar.availability(of: focused, rankIndex: progress.rank.index, blueStars: blueStars.blueStars)
        if hangar.selectedSkin == focused {
            label("EQUIPPED", icon: "checkmark.circle.fill", colors: [.gray.opacity(0.5), .gray.opacity(0.4)])
        } else {
            switch availability {
            case .owned:
                Button(action: { hangar.select(focused) }) {
                    label("EQUIP", icon: "paintbrush.fill", colors: [.orange, .red])
                }
            case .unlockedByRank:
                Button(action: acquireFocused) {
                    label("CLAIM — RANK REWARD", icon: "gift.fill", colors: [.green, .teal])
                }
            case .purchasable(let price):
                Button(action: acquireFocused) {
                    label("UNLOCK FOR \(price) \u{2605}", icon: "lock.open.fill", colors: [.cyan, .blue])
                }
            case .locked(let price, let rankIndex):
                VStack(spacing: 4) {
                    label(lockedTitle(price: price, rankIndex: rankIndex), icon: "lock.fill", colors: [.gray.opacity(0.35), .gray.opacity(0.25)])
                    if let price = price {
                        Text("\(max(0, price - blueStars.blueStars)) more Blue Stars needed")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }

    private func skinCard(_ skin: ShipSkin) -> some View {
        let owned = hangar.ownedSkins.contains(skin)
        let equipped = hangar.selectedSkin == skin
        return Button(action: { focused = skin }) {
            VStack(spacing: 4) {
                ShipPreviewView(skin: skin, showsFlame: false)
                    .frame(height: 80)
                    .opacity(owned ? 1 : 0.55)
                Text(skin.displayName)
                    .font(.custom("Orbitron", size: 9).weight(.bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Group {
                    if equipped {
                        Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    } else if owned {
                        Text("OWNED").foregroundColor(.gray)
                    } else if skin.price > 0 {
                        Text("\(skin.price) \u{2605}").foregroundColor(.cyan)
                    } else {
                        Image(systemName: "lock.fill").foregroundColor(.gray)
                    }
                }
                .font(.system(size: 10, weight: .bold, design: .monospaced))
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(focused == skin ? 0.12 : 0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focused == skin ? Color.orange.opacity(0.7) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: Helpers

    private func acquireFocused() {
        if hangar.acquire(focused, rankIndex: progress.rank.index, blueStarManager: blueStars) {
            hangar.select(focused)
            HapticManager.shared.landingSuccess()
        } else {
            showingPurchaseError = true
        }
    }

    private func lockedTitle(price: Int?, rankIndex: Int?) -> String {
        if let rankIndex = rankIndex, rankIndex < PilotRank.all.count {
            let rankTitle = PilotRank.all[rankIndex].title.uppercased()
            if let price = price { return "\(rankTitle) OR \(price) \u{2605}" }
            return "REACH \(rankTitle)"
        }
        if let price = price { return "\(price) \u{2605} TO UNLOCK" }
        return "LOCKED"
    }

    private func label(_ text: String, icon: String, colors: [Color]) -> some View {
        HStack {
            Image(systemName: icon)
            Text(text)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .font(.custom("Orbitron", size: 14).weight(.bold))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .background(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
        .cornerRadius(12)
    }
}
