import SpriteKit

// MARK: - Sound Methods
// Every sound respects the Sound setting (GameState.soundEnabled).
extension GameScene {

    func startThrustSound() {
        guard gameState.soundEnabled, !isThrustSoundPlaying else { return }

        if let url = Bundle.main.url(forResource: "thrust", withExtension: "wav") {
            let sound = SKAudioNode(url: url)
            sound.autoplayLooped = true
            addChild(sound)
            sound.run(SKAction.sequence([
                SKAction.changeVolume(to: 0.5, duration: 0),
                SKAction.play()
            ]))
            thrustSound = sound
            isThrustSoundPlaying = true
        }
    }

    func stopThrustSound() {
        if let sound = thrustSound {
            sound.run(SKAction.stop())
            sound.removeFromParent()
        }
        thrustSound = nil
        isThrustSoundPlaying = false
    }

    func playRotateSound() {
        play("rotate.wav")
    }

    func playSuccessSound() {
        play("land_success.wav")
    }

    func playExplosionSound() {
        play("explosion.wav")
    }

    func playChallengeFailSound() {
        play("challenge_fail.wav")
    }

    private func play(_ file: String) {
        guard gameState.soundEnabled else { return }
        run(SKAction.playSoundFileNamed(file, waitForCompletion: false))
    }
}
