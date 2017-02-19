//: Playground - noun: a place where people can play

import Cocoa
import AVFoundation
import XCPlayground

open class Meter: NSView {
    
    var bar: CAGradientLayer!
    var mask: CALayer!
    var recorder: AVAudioRecorder!
    var timer: Timer!
    var label: NSTextField!
    let minDecibels: Float = -80
    public var updated: ((Float) -> Void)?
    
    // Convert the raw decibel into a level from 0 - 1
    var level: Float {
        
        let decibels = recorder.averagePower(forChannel: 0)
        
        if decibels < minDecibels {
            return 0
        } else if decibels >= 0 {
            return 1
        }
        
        let minAmp = powf(10, 0.05 * minDecibels)
        let inverseAmpRange = 1 / (1 - minAmp)
        let amp = powf(10, 0.05 * decibels)
        let adjAmp = (amp - minAmp) * inverseAmpRange
        
        return sqrtf(adjAmp)
        
    }
    
    var pos: Float {
        // linear level * by max + min scale (20 - 130db)
        return level * 130 + 20
    }
    
    let settings: [String:Any] = [
        AVFormatIDKey: kAudioFormatLinearPCM,
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVLinearPCMBitDepthKey: 16,
        AVLinearPCMIsBigEndianKey: false,
        AVLinearPCMIsFloatKey: false
    ]
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        do {
            let url = URL(string: NSTemporaryDirectory().appending("tmp.caf"))!
            Swift.print("recording to")
            Swift.print(url)
            try recorder = AVAudioRecorder(url: url, settings: settings)
        } catch {
            Swift.print("error!")
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        
        addBar()
        addLabel()
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLabel() {
        label = NSTextField(frame: CGRect(x: 0, y: 50, width: 200, height: 50))
        label.textColor = NSColor.white
        label.font = NSFont.systemFont(ofSize: 24)
        label.isEditable = false
        label.stringValue = "0dB"
        label.backgroundColor = NSColor.black
        label.isBordered = false
        addSubview(label)
    }
    
    func addBar() {
        
        mask = CALayer()
        mask.frame = CGRect(x: 0, y: 0, width: 0, height: 50)
        mask.masksToBounds = true
        layer?.addSublayer(mask)
        
        
        let color1 = NSColor(red:1.00, green:0.00, blue:0.80, alpha:1.0).cgColor
        let color2 = NSColor(red:0.20, green:0.20, blue:0.60, alpha:1.0).cgColor
        bar = CAGradientLayer()
        bar.startPoint = CGPoint(x: 0, y: 0)
        bar.endPoint = CGPoint(x: 1, y: 0)
        bar.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 50)
        bar.colors = [color2, color1]

        mask.addSublayer(bar)
    }
    
    
    func updateMeter() {
        recorder.updateMeters()
        updated?(pos)
        label.stringValue = "\(Int(pos))dB"
        
        mask.frame = CGRect(x: 0, y: 0, width: frame.size.width * CGFloat(level), height: bar.bounds.size.height)
    }
    
}
