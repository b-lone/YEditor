//
//  ViewController.swift
//  YEditor
//
//  Created by 尤坤 on 2023/2/27.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var commandLineTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


    @IBAction func onButton(_ sender: Any) {
        let panel = NSOpenPanel()
        panel.title = "Select a folder"
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.runModal()
        
        guard let fileURL = panel.url else { return }

        do {
            // 读取文件内容
            let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
            
            // 将每行数据拼接成一个字符串，并用逗号隔开
            let dataArray = fileContents.split(separator: "\n")
            let joinedString = dataArray.joined(separator: ",")
            
            writeToFile(content: joinedString)
            
        } catch {
            print("Error reading file: \(error)")
        }
    }
    
    private func writeToFile(content: String) {
        let panel = NSSavePanel()
        panel.directoryURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        panel.runModal()
        
       guard let fileURL = panel.url else { return }
        
        let writePath = fileURL.path
        if !FileManager.default.fileExists(atPath: writePath) {
            FileManager.default.createFile(atPath: writePath, contents: nil)
        }
        do {
            try content.write(toFile: writePath, atomically: false, encoding: .utf8)
        } catch {
            print("Error writing file: \(error)")
        }
    }
    
    @IBAction func onUrlButton(_ sender: Any) {
        let urlString = self.urlTextField.stringValue
        if let url = URL(string: urlString) {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                // 访问各个URL部分
                print(components.scheme ?? "")    // "https"
                print(components.host ?? "")      // "www.example.com"
                print(components.path)            // "/search"
                print(components.query ?? "")     // "q=swift&page=1"
                
                // 将查询参数解析为字典
                if let queryItems = components.queryItems {
                    var queryParams = [String: String]()
                    for item in queryItems {
                        queryParams[item.name] = item.value
                    }
                    print(queryParams)          // ["q": "swift", "page": "1"]
                }
            }
        }
    }
    
    @IBAction func onCommandLineButton(_ sender: Any) {
        let command = self.commandLineTextField.stringValue
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe
        
        process.launch()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .newlines)
        
        process.waitUntilExit()
        
        print(output)
    }
}

