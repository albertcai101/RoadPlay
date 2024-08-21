import SwiftUI
import CoreMotion
import Charts

struct ContentView: View {
    // set up motion manager
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    // record the values
    @State var accelX: [Double] = []
    @State var accelY: [Double] = []
    @State var accelZ: [Double] = []
    
    @State var angleVelX: [Double] = []
    @State var angleVelY: [Double] = []
    @State var angleVelZ: [Double] = []
    
    var body: some View {
        ScrollView {
            HStack {
                VStack {
                    Text("Acceleration:")
                        .font(.caption)
                    Text("\(accelZ.last ?? 0.0, specifier: "%.2f") g")
                        .font(.headline)
                }
                .padding(.horizontal)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text("Angular Velocity:")
                        .font(.caption)
                    Text("\(angleVelZ.last ?? 0.0, specifier: "%.2f") rad/s")
                        .font(.headline)
                }
                .padding(.horizontal)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            }
            VStack {
                // For now only care about -Z axis
                Chart {
                    ForEach(Array(accelZ.enumerated()), id: \.offset) { index, value in
                        LineMark(x: .value("Time", index), y: .value("Acceleration Z", value))
                            .foregroundStyle(.red)
                            .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: -3...3)
                .frame(height: 300)
                .padding()
                
                // For now only care about angular velocity about Y
                Chart {
                    ForEach(Array(angleVelY.enumerated()), id: \.offset) { index, value in
                        LineMark(x: .value("Time", index), y: .value("Angular Velocity Y", value))
                            .foregroundStyle(.blue)
                            .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: -10...10)
                .frame(height: 300)
                .padding()
            }
        }
        .onAppear {
            var lastUpdateTime = Date()
            self.motionManager.startDeviceMotionUpdates(to: self.queue) {
                (data: CMDeviceMotion?, error: Error?) in
                
                let gyro: CMRotationRate = data!.rotationRate
                let acceleration: CMAcceleration = data!.userAcceleration
                
                // Throttle updates to every 0.1 seconds
                if Date().timeIntervalSince(lastUpdateTime) >= 0.1 {
                    lastUpdateTime = Date()
                    DispatchQueue.main.async {
                        accelX.append(Double(acceleration.x))
                        accelY.append(Double(acceleration.y))
                        accelZ.append(Double(acceleration.z))
                        
                        angleVelX.append(Double(gyro.x))
                        angleVelY.append(Double(gyro.y))
                        angleVelZ.append(Double(gyro.z))
                        
                        if accelX.count > 100 {
                            accelX.removeFirst()
                            accelY.removeFirst()
                            accelZ.removeFirst()
                            angleVelX.removeFirst()
                            angleVelY.removeFirst()
                            angleVelZ.removeFirst()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
