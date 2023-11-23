//
//  Synth.swift
//  Swift Synth
//
//  Created by Grant Emerson on 7/21/19.
//  Copyright © 2019 Grant Emerson. All rights reserved.
//

import AVFoundation

class Synth {
    public static let shared = Synth()
    private var audioEngine: AVAudioEngine
    
    private var time: Float = 0
    private let sampleRate: Double
    private let deltaTime: Float
    
    private var signal: Signal
    
    public var frequencyRampValue: Float = 0
    
    public var frequency: Float = 440 {
        didSet {
            if oldValue != 0 {
                frequencyRampValue = frequency - oldValue
            } else {
                frequencyRampValue = 0
            }
        }
    }

    public var volume: Float {
        set {
            audioEngine.mainMixerNode.outputVolume = newValue
        }
        get {
            audioEngine.mainMixerNode.outputVolume
        }
    }

    // Changes gradually the volume of the sound.
    public func changeVolume(_ volume: Float) {
        // creates the transition that changes the volume gradually
        let changeVolume = AVAudioUnitTimePitch()
        changeVolume.pitch = 1.0
        changeVolume.rate = 1.0
        changeVolume.overlap = 8.0
    }
    
    // Gradually changes the volume of the sound.
    public func changeSoundPan(_ pan: Float) {
        // creates the transition that changes the sound gradually
        let changeSoundPan = AVAudioUnitTimePitch()
        changeSoundPan.pitch = pan
        changeSoundPan.rate = 1.0
        changeSoundPan.overlap = 8.0
    }

    private lazy var sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                
        let localRampValue = self.frequencyRampValue
        let localFrequency = self.frequency - localRampValue
        
        let period = 1 / localFrequency

        for frame in 0..<Int(frameCount) {
            let percentComplete = self.time / period
            let sampleVal = self.signal(localFrequency + localRampValue * percentComplete, self.time)
            self.time += self.deltaTime
            self.time = fmod(self.time, period)
            
            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = sampleVal
            }
        }
        
        self.frequencyRampValue = 0
        
        return noErr
    }
    
    // Init
    init(signal: @escaping Signal = Oscillator.sine) {
        audioEngine = AVAudioEngine()
        
        let mainMixer = audioEngine.mainMixerNode
        let outputNode = audioEngine.outputNode
        let format = outputNode.inputFormat(forBus: 0)
        
        sampleRate = format.sampleRate
        deltaTime = 1 / Float(sampleRate)
        
        self.signal = signal
        
        let inputFormat = AVAudioFormat(commonFormat: format.commonFormat,
                                        sampleRate: format.sampleRate,
                                        channels: 1,
                                        interleaved: format.isInterleaved)
        
        audioEngine.attach(sourceNode)
        audioEngine.connect(sourceNode, to: mainMixer, format: inputFormat)
        audioEngine.connect(mainMixer, to: outputNode, format: nil)
        mainMixer.outputVolume = 0
        
        do {
            try audioEngine.start()
        } catch {
            print("Could not start engine: \(error.localizedDescription)")
        }
        
    }
    
    // MARK: Public Functions
    public func setWaveformTo(_ signal: @escaping Signal) {
        self.signal = signal
    }
}
