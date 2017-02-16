import Cocoa
import XCPlayground



XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
let meter = Meter(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
//meter.updated = { value in
//    Swift.print(value)
//}
XCPlaygroundPage.currentPage.liveView = meter