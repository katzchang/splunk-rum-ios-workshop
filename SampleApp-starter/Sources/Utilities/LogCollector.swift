import Foundation
import os

/// Collects stderr output (including NSLog) and forwards to Splunk HEC
class LogCollector {
    static let shared = LogCollector()

    private var stderrPipe: [Int32] = [0, 0]
    private var savedStderr: Int32 = 0
    private var isRunning = false

    /// Splunk HEC configuration (loaded from Info.plist)
    private let hecURL: String?
    private let hecToken: String?

    var isHECConfigured: Bool {
        guard let url = hecURL, let token = hecToken else { return false }
        return !url.isEmpty && !token.isEmpty
    }

    // Use os.Logger for debug output (doesn't go through stderr)
    private let logger = Logger(subsystem: "com.example.RUMSampleApp", category: "LogCollector")

    private let urlSession: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        self.urlSession = URLSession(configuration: config)

        // Load HEC configuration from Info.plist
        self.hecURL = Bundle.main.object(forInfoDictionaryKey: "SplunkHECURL") as? String
        self.hecToken = Bundle.main.object(forInfoDictionaryKey: "SplunkHECToken") as? String
    }

    func start() {
        guard !isRunning else { return }

        guard isHECConfigured else {
            logger.warning("Splunk HEC not configured. Set SplunkHECURL and SplunkHECToken in Info.plist")
            return
        }

        isRunning = true
        logger.info("LogCollector starting (stderr capture)...")

        // Save original stderr
        savedStderr = dup(STDERR_FILENO)

        // Create pipe for stderr
        pipe(&stderrPipe)

        // Redirect stderr to pipe (NSLog also goes to stderr)
        dup2(stderrPipe[1], STDERR_FILENO)

        // Start reading from pipe in background
        startReadLoop()
    }

    func stop() {
        guard isRunning else { return }
        isRunning = false

        // Restore original stderr
        dup2(savedStderr, STDERR_FILENO)

        // Close pipes
        close(stderrPipe[0])
        close(stderrPipe[1])
        close(savedStderr)

        logger.info("LogCollector stopped")
    }

    private func startReadLoop() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let bufferSize = 2048
            var buffer = [UInt8](repeating: 0, count: bufferSize)

            while self?.isRunning == true {
                guard let self = self else { break }

                let bytesRead = read(self.stderrPipe[0], &buffer, bufferSize)
                if bytesRead > 0 {
                    let data = Data(bytes: buffer, count: bytesRead)

                    // Write to original stderr (so Xcode console still works)
                    _ = data.withUnsafeBytes { ptr in
                        write(self.savedStderr, ptr.baseAddress, bytesRead)
                    }

                    // Send to Splunk HEC
                    if let message = String(data: data, encoding: .utf8) {
                        self.sendToHEC(message: message)
                    }
                }
            }
        }
    }

    private func sendToHEC(message: String) {
        let lines = message.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }

        for line in lines {
            sendLineToHEC(line: line)
        }
    }

    private func sendLineToHEC(line: String) {
        guard let urlString = hecURL, let token = hecToken,
              let url = URL(string: urlString) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Splunk \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "event": line,
            "sourcetype": "ios_app_log",
            "source": "RUMSampleApp"
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            logger.error("Failed to serialize HEC payload: \(error.localizedDescription)")
            return
        }

        urlSession.dataTask(with: request) { [weak self] _, response, error in
            if let error = error {
                self?.logger.error("HEC request failed: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                self?.logger.error("HEC returned status: \(httpResponse.statusCode)")
            }
        }.resume()
    }
}
