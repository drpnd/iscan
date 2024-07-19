import Foundation
import CoreWLAN

// To write to stderr
var standardError = FileHandle.standardError
extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        let data = Data(string.utf8)
        self.write(data)
    }
}

// Override the CWChannelWidth enum for String description
extension CWChannelWidth: CustomStringConvertible {
    public var description: String {
        switch self {
        case .width20MHz: return "20"
        case .width40MHz: return "40"
        case .width80MHz: return "80"
        default: return "Unknown"
        }
    }
}

class WiFiNetworkScanner {
    var currentInterface: CWInterface

    init?() {
        guard let defaultInterface = CWWiFiClient.shared().interface(),
              defaultInterface.interfaceName != nil else {
            return nil
        }
        self.currentInterface = defaultInterface
    }

    func scanNetworks() {
        do {
            let networks = try currentInterface.scanForNetworks(withName: nil, includeHidden: true)
            for network in networks {
                printNetwork(withNetwork: network)
            }
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
    }

    func printNetwork(withNetwork network: CWNetwork) {
        let ssid = network.ssid ?? "(hidden)"
        let channelWidth = network.wlanChannel?.channelWidth ?? CWChannelWidth.widthUnknown
        print("\(ssid.padding(toLength: 32, withPad: " ", startingAt: 0)) \(network.bssid ?? "--")\t\(network.wlanChannel?.channelNumber ?? -1)\t\(String(describing: channelWidth))\t\(network.rssiValue)\t\(network.noiseMeasurement)\t\(network.countryCode ?? "--")\t\(network.beaconInterval)")
    }
}

let scanner = WiFiNetworkScanner()
print("Wi-Fi interface: \(scanner?.currentInterface.interfaceName ?? "no interface specified.")", to: &standardError)
scanner?.scanNetworks()
