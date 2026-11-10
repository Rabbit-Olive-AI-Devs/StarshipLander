import SwiftUI

struct HowToPlayView: View {
    let useAccelerometer: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header bar
                HStack {
                    Text("How to Play")
                        .font(.custom("Orbitron", size: 20).weight(.bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        controlsSection
                        flightAidsSection
                        platformsSection
                        speedBandsSection
                        scoringSection
                        campaignSection
                        dailyChallengeSection
                        blueStarsSection
                        pilotRankSection
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Controls

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Controls")

            controlRow(icon: "flame.fill", color: .orange,
                       title: "Thrust",
                       detail: "Hold the THRUST button to fire the engine and slow your descent.")

            if useAccelerometer {
                controlRow(icon: "iphone.gen3.radiowaves.left.and.right", color: .blue,
                           title: "Rotate",
                           detail: "Tilt your phone left or right to rotate the rocket.")
            } else {
                controlRow(icon: "arrow.left.arrow.right", color: .blue,
                           title: "Rotate",
                           detail: "Use the L/R buttons on screen to rotate the rocket.")
            }

            controlRow(icon: "arrow.down.to.line", color: .green,
                       title: "Land",
                       detail: "Touch down on a platform slowly, level, and centered for the best score.")
        }
    }

    private func controlRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Platforms

    private var platformsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Landing Platforms")

            Text("Three platforms with different difficulty and rewards:")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                // Header row
                HStack {
                    Text("Pad").frame(width: 30, alignment: .leading)
                    Text("Name").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Width").frame(width: 45, alignment: .trailing)
                    Text("Mult").frame(width: 35, alignment: .trailing)
                    Text("Stars").frame(width: 40, alignment: .trailing)
                }
                .font(.system(.caption2, design: .monospaced).bold())
                .foregroundColor(.orange)
                .padding(.vertical, 6)
                .padding(.horizontal, 8)

                platformRow("A", "Training Zone", "130", "1x", 1, color: .green)
                platformRow("B", "Precision Target", "110", "2x", 2, color: .yellow)
                platformRow("C", "Elite Landing", "80", "5x", 3, color: .red)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private func platformRow(_ pad: String, _ name: String, _ width: String, _ mult: String, _ stars: Int, color: Color) -> some View {
        HStack {
            Text(pad)
                .foregroundColor(color)
                .frame(width: 30, alignment: .leading)
            Text(name).frame(maxWidth: .infinity, alignment: .leading)
            Text(width).frame(width: 45, alignment: .trailing)
            Text(mult).frame(width: 35, alignment: .trailing)
            HStack(spacing: 1) {
                ForEach(0..<stars, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                }
            }
            .frame(width: 40, alignment: .trailing)
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundColor(.white)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    // MARK: - Speed Bands

    private var speedBandsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Speed Bands")

            VStack(alignment: .leading, spacing: 6) {
                bandExplanation(band: "SAFE", color: .green,
                                detail: "Below safe threshold — full points for speed components.")
                bandExplanation(band: "HARD", color: .yellow,
                                detail: "Between safe and hard thresholds — you survive but lose speed points.")
                bandExplanation(band: "FAIL", color: .red,
                                detail: "Above hard threshold — crash! No landing.")
            }

            Text("Thresholds per platform (vertical / horizontal):")
                .font(.caption2)
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                HStack {
                    Text("Pad").frame(width: 30, alignment: .leading)
                    Text("Safe V").frame(width: 50, alignment: .trailing)
                    Text("Hard V").frame(width: 50, alignment: .trailing)
                    Text("Safe H").frame(width: 50, alignment: .trailing)
                    Text("Hard H").frame(width: 50, alignment: .trailing)
                }
                .font(.system(.caption2, design: .monospaced).bold())
                .foregroundColor(.orange)
                .padding(.vertical, 6)
                .padding(.horizontal, 8)

                thresholdRow("A", "70", "100", "50", "80", color: .green)
                thresholdRow("B", "50", "75", "40", "60", color: .yellow)
                thresholdRow("C", "33", "52", "28", "48", color: .red)
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)

            Text("Tilt: ≤2.9° safe (full points), ≤5.7° hard (partial credit), >5.7° crash.")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private func bandExplanation(band: String, color: Color, detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(band)
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundColor(color)
                .frame(width: 40, alignment: .leading)
            Text(detail)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private func thresholdRow(_ pad: String, _ sv: String, _ hv: String, _ sh: String, _ hh: String, color: Color) -> some View {
        HStack {
            Text(pad)
                .foregroundColor(color)
                .frame(width: 30, alignment: .leading)
            Text(sv).frame(width: 50, alignment: .trailing)
            Text(hv).frame(width: 50, alignment: .trailing)
            Text(sh).frame(width: 50, alignment: .trailing)
            Text(hh).frame(width: 50, alignment: .trailing)
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundColor(.white)
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }

    // MARK: - Scoring

    private var scoringSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Scoring")

            Text("Your score is calculated from 6 components, then multiplied:")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 4) {
                scoreComponent("Base", "100 pts", "Awarded for any successful landing")
                scoreComponent("Soft Landing", "0-550 pts", "Lower vertical speed = more points")
                scoreComponent("Horizontal Precision", "0-450 pts", "Lower sideways speed = more points")
                scoreComponent("Platform Center", "0-600 pts", "Closer to center = more points")
                scoreComponent("Rotation Precision", "0-250 pts", "More level = more points")
                scoreComponent("Approach Control", "0-150 pts", "Smooth final approach = more points")
            }

            Text("Subtotal max: 2,100 pts")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top) {
                    Text("Fuel Multiplier:")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    Text("1.0x (empty) to 2.2x (full tank)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                HStack(alignment: .top) {
                    Text("Platform Multiplier:")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    Text("A = 1x, B = 2x, C = 5x")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Text("Final = Subtotal x Fuel x Platform")
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundColor(.orange)

            Text("Max possible: 2,100 x 2.2 x 5.0 = 23,100 pts")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private func scoreComponent(_ name: String, _ points: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(points)
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.orange)
                .frame(width: 70, alignment: .trailing)
            VStack(alignment: .leading, spacing: 1) {
                Text(name)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text(detail)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Campaign

    private var campaignSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Campaign")

            Text("Land on 10 worlds across the solar system. Each planet has unique gravity, thrust, and a special mechanic. Complete a level to unlock the next.")
                .font(.caption)
                .foregroundColor(.gray)

            Text("Stars are earned by landing on harder platforms: A = 1 star, B = 2 stars, C = 3 stars. Collect all 30 stars to master the campaign.")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(spacing: 0) {
                ForEach(LevelDefinition.levels, id: \.id) { level in
                    campaignLevelRow(level)
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
    }

    private func campaignLevelRow(_ level: LevelDefinition) -> some View {
        HStack(spacing: 8) {
            Text("\(level.id)")
                .font(.system(.caption, design: .monospaced).bold())
                .foregroundColor(.orange)
                .frame(width: 20, alignment: .trailing)

            VStack(alignment: .leading, spacing: 1) {
                Text(level.name)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text(level.description)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("g: \(String(format: "%.1f", abs(level.gravity)))")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
                if level.specialMechanic != .none {
                    Text(level.specialMechanic.displayName)
                        .font(.system(size: 9))
                        .foregroundColor(.orange.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
    }

    // MARK: - Daily Challenge

    private var dailyChallengeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Daily Challenge")

            Text("A new challenge every day, the same for all players worldwide. Each challenge sets specific objectives you must meet in a single landing.")
                .font(.caption)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 6) {
                constraintRow(icon: "scope", label: "Target Platform", detail: "Land on a specific platform (A, B, or C)")
                constraintRow(icon: "rotate.right", label: "Max Tilt", detail: "Keep your tilt angle below the limit")
                constraintRow(icon: "arrow.down", label: "Max V. Speed", detail: "Touch down below a vertical speed limit")
                constraintRow(icon: "arrow.left.arrow.right", label: "Max H. Speed", detail: "Control your horizontal drift")
                constraintRow(icon: "fuelpump.fill", label: "Min Fuel", detail: "Land with enough fuel remaining")
                constraintRow(icon: "timer", label: "Time Limit", detail: "Complete the landing within a time limit")
            }

            Text("Challenges combine multiple objectives and rotate across all 10 planets. Difficulty ranges from 1 to 5 stars.")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private func constraintRow(icon: String, label: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(.teal)
                .frame(width: 20)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text(detail)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Flight Aids

    private var flightAidsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Flight Aids")
            controlRow(icon: "arrow.down.to.line.compact", color: .green,
                       title: "Guide Line",
                       detail: "Near the ground a line drops from your legs to the surface. Green means both legs fit the pad below; yellow means you're on the edge.")
            controlRow(icon: "speedometer", color: .yellow,
                       title: "Descent Readout",
                       detail: "The \u{2193} speed and altitude beside your ship turn green, yellow or red using the limits of the pad below you.")
            controlRow(icon: "gyroscope", color: .cyan,
                       title: "RCS Attitude Hold",
                       detail: "Release rotation and the ship's thrusters damp any spin, as long as you have fuel.")
        }
    }

    // MARK: - Pilot Rank

    private var pilotRankSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Pilot Rank & Hangar")
            Text("Every flight earns XP. Landings earn more: harder pads, clean touchdowns, landing streaks and daily challenges add bonuses. Each promotion awards \(PilotProgress.blueStarsPerPromotion) Blue Stars.")
                .font(.caption)
                .foregroundColor(.gray)
            VStack(alignment: .leading, spacing: 4) {
                ForEach(PilotRank.all, id: \.index) { rank in
                    HStack(spacing: 8) {
                        Image(systemName: rank.icon)
                            .font(.system(size: 10))
                            .foregroundColor(.cyan)
                            .frame(width: 18)
                        Text(rank.title)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(rank.xpRequired) XP")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
            }
            Text("Spend Blue Stars in the Hangar on new Starship paint schemes. Some schemes unlock for free when you reach a rank.")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    // MARK: - Blue Stars

    private var blueStarsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Blue Stars")

            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.cyan)
                Text("Blue Stars are a special currency earned through skill and dedication.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading, spacing: 8) {
                rewardRow(title: "Daily Challenge", detail: "+1 Blue Star for completing a daily challenge", icon: "calendar.badge.clock", color: .teal)
                rewardRow(title: "5-Day Streak", detail: "+3 bonus Blue Stars for 5 consecutive days", icon: "flame.fill", color: .orange)
                rewardRow(title: "10 Campaign Stars", detail: "+10 Blue Stars milestone", icon: "star.fill", color: .yellow)
                rewardRow(title: "20 Campaign Stars", detail: "+50 Blue Stars milestone", icon: "star.fill", color: .yellow)
                rewardRow(title: "30 Campaign Stars", detail: "+150 Blue Stars milestone", icon: "star.fill", color: .yellow)
                rewardRow(title: "Pilot Rank Promotion", detail: "+\(PilotProgress.blueStarsPerPromotion) Blue Stars every time you rank up", icon: "chevron.up.circle.fill", color: .cyan)
            }

            Text("Campaign milestones are one-time rewards. Daily challenges and streaks can be earned every day.")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }

    private func rewardRow(title: String, detail: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
                .frame(width: 20)
                .padding(.top, 1)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.white)
                Text(detail)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.bold())
            .foregroundColor(.orange)
            .tracking(1)
    }
}
