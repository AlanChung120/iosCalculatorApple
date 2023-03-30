//
//  CalcViewController.swift
//  Calculator
//
//  Created by Alan Chung on 2023-03-16.
//

import UIKit

// support substring
extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }

    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

class CalcViewController: UIViewController {

    @IBOutlet var result: UILabel!
    
    enum Operation {
        case divide
        case multiply
        case add
        case substract
        case none
    }
    
    let error: String = "Math Error"
    let maxChar: Int = 10
    var answer: Double = 0
    var secondInput: Bool = false
    var resultPrev: Bool = false
    var operation: Operation = .none
    var currentNum: Int = 0
    var numbers: [String] = ["0", ""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // get the index (int) of the given character in the given string
    func indexOf(str: String, char: String.Element) -> Int {
        if let i = str.firstIndex(of: char) {
            let index: Int = str.distance(from: str.startIndex, to: i)
            return index
        } else {
            return -1
        }
    }
    
    func formatNum(n: String) -> String {
        
        // Fix double calculation outliers
        var num: String = n
        var numFormatted: String = ""
        var decimalSpot: Int = indexOf(str: num, char: ".")
        var eSpot: Int = indexOf(str: num, char: "e")
        if (resultPrev && (Double(num) ?? 0 > 9999999999 || Double(num) ?? 0 < -9999999999) && eSpot == -1) {
            eSpot = num.count
            if (Array(num)[0] == "-") {
                num = num.substring(with: 0..<2) + "." + num.substring(with: 2..<decimalSpot) + num.substring(from: decimalSpot+1) + "e+" +
                String(decimalSpot - 1)
            } else {
                num = num.substring(with: 0..<1) + "." + num.substring(with: 1..<decimalSpot) + num.substring(from: decimalSpot+1) + "e+" +
                String(decimalSpot - 1)
            }
        }
        if (eSpot != -1 && indexOf(str: num, char: ".") == -1) {
            if (Array(num)[0] == "-") {
                num = num.substring(with: 0..<2) + ".0" + num.substring(from: 2)
            } else {
                num = num.substring(with: 0..<1) + ".0" + num.substring(from: 1)
            }
        }
        
        if (num == error) {
            numFormatted = error
        } else if (num.contains("e") &&
                   (Int(num.substring(from: indexOf(str: num, char: "e") + 1)) ?? 0 > 100 ||
                    Int(num.substring(from: indexOf(str: num, char: "e") + 1)) ?? 0 < -100)) {
            numFormatted = error
        } else {
            
            // Round the result
            var numOnly: String = ""
            if (decimalSpot != -1 && resultPrev && num.count > maxChar + 1) {
                var roundTo: Int = 0
                if (eSpot != -1) {
                    numOnly = num.substring(with:0..<eSpot)
                    roundTo = 6
                } else {
                    numOnly = num
                    if (Array(num)[0] == "-") {
                        roundTo = maxChar - decimalSpot + 1
                    } else {
                        roundTo = maxChar - decimalSpot
                    }
                }
                let toRound: Double = Double(numOnly) ?? 0
                numOnly = String(round(toRound * pow(10, Double(roundTo))) / pow(10, Double(roundTo)))
                if (eSpot != -1) {
                    if (numOnly == "10.0") {
                        numOnly = "1.0e" + num.substring(with: eSpot+1..<eSpot+2) + String((Int(num.substring(from: eSpot + 1)) ?? 0) + 1)
                    } else {
                        numOnly += num.substring(from: eSpot)
                    }
                }
                num = numOnly
                
            }

            // Add commas
            decimalSpot = indexOf(str: num, char: ".")
            if (decimalSpot == -1) {
                decimalSpot = num.count
            }
            if (Array(num)[0] == "-") {
                numFormatted += "-"
                numOnly = num.substring(with: 1..<decimalSpot)
            } else {
                numOnly = num.substring(with: 0..<decimalSpot)
            }
            for i in 0..<numOnly.count {
                if ((numOnly.count - i) % 3 == 0 && i !=  0) {
                    numFormatted += "," + numOnly.substring(with: i..<i+1)
                } else {
                    numFormatted += numOnly.substring(with: i..<i+1)
                }
            }
            
            //format decimals
            if (decimalSpot != num.count &&
                !(num.hasSuffix(".0") && resultPrev)) {
                numFormatted += num.substring(from: decimalSpot)
            }
        }
        return numFormatted
        
    }
    
    // calculate for calculator
    func calculate(op: Operation, num1: String, num2: String) -> String {
        var ans: String = ""
        switch op {
        case .divide:
            if (num2 == "0" || num2 == "0.") {
                ans = error
            } else {
                ans = String((Double(num1) ?? 0) / (Double(num2)!))
            }
        case .multiply:
            ans = String((Double(num1) ?? 0) * (Double(num2) ?? 0))
        case .add:
            ans = String((Double(num1) ?? 0) + (Double(num2) ?? 0))
        case .substract:
            ans = String((Double(num1) ?? 0) - (Double(num2) ?? 0))
        case .none:
            ans = "0"
        }
        return ans
    }
    
    func preButton() {
        if (secondInput) {
            currentNum = 1
        }
        if (numbers[0] == error) {
            secondInput = false
            resultPrev = false
            operation = .none
            currentNum = 0
            numbers[0] = "0"
            numbers[1] = ""
        }
    }
    
    @IBAction func acTapped(_ sender: UIButton) {
        preButton()
        
        secondInput = false
        resultPrev = false
        operation = .none
        currentNum = 0
        numbers[0] = "0"
        numbers[1] = ""
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func signTapped(_ sender: UIButton) {
        preButton()
        
        if (numbers[1] == "" && currentNum == 1) {
            numbers[1] = "0"
        }
        if (Array(numbers[currentNum])[0] == "-") {
            numbers[currentNum] = numbers[currentNum].substring(from: 1)
        } else {
            numbers[currentNum] = "-" + numbers[currentNum]
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func percentTapped(_ sender: UIButton) {
        preButton()
        
        if (numbers[1] == "" && currentNum == 1) {
            numbers[1] = numbers[0]
        }
        answer = Double(numbers[currentNum]) ?? 0
        answer *= 0.01
        numbers[currentNum] = String(answer)
        resultPrev = true
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func divideTapped(_ sender: UIButton) {
        preButton()
        
        if (operation != .none && numbers[1] != "" && secondInput) {
            numbers[0] = calculate(op: operation, num1: numbers[0], num2: numbers[1])
            resultPrev = true
        } else {
            secondInput = true
        }
        operation = .divide
        currentNum = 0
        numbers[1] = ""
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func multiplyTapped(_ sender: UIButton) {
        preButton()
        
        if (operation != .none && numbers[1] != "" && secondInput) {
            numbers[0] = calculate(op: operation, num1: numbers[0], num2: numbers[1])
            resultPrev = true
        } else {
            secondInput = true
        }
        operation = .multiply
        currentNum = 0
        numbers[1] = ""
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func minusTapped(_ sender: UIButton) {
        preButton()
        
        if (operation != .none && numbers[1] != "" && secondInput) {
            numbers[0] = calculate(op: operation, num1: numbers[0], num2: numbers[1])
            resultPrev = true
        } else {
            secondInput = true
        }
        operation = .substract
        currentNum = 0
        numbers[1] = ""
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func plusTapped(_ sender: UIButton) {
        preButton()
        
        if (operation != .none && numbers[1] != "" && secondInput) {
            numbers[0] = calculate(op: operation, num1: numbers[0], num2: numbers[1])
            resultPrev = true
        } else {
            secondInput = true
        }
        operation = .add
        currentNum = 0
        numbers[1] = ""
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func equalsTapped(_ sender: UIButton) {
        preButton()
        
        if (numbers[1] == "") {
            numbers[1] = numbers[0]
        }
        numbers[0] = calculate(op: operation, num1: numbers[0], num2: numbers[1])
        currentNum = 0
        secondInput = false
        resultPrev = true
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func dotTapped(_ sender: UIButton) {
        preButton()
        
        if (numbers[1] == "" && currentNum == 1) {
            numbers[1] = "0"
        }
        if (resultPrev) {
            numbers[currentNum] = "0."
            resultPrev = false
        } else if (!numbers[currentNum].contains(".")) {
            numbers[currentNum] += "."
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num0Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] != "0" && numbers[currentNum] != "-0" &&
            (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar)) {
            numbers[currentNum] += "0"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num1Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "1")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "1"
        }

        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num2Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "2")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "2"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num3Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "3")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "3"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num4Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "4")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "4"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num5Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "5")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "5"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num6Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "6")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "6"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num7Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "7")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "7"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num8Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "8")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "8"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    @IBAction func num9Tapped(_ sender: UIButton) {
        preButton()
        
        if (resultPrev && currentNum == 0) {
            resultPrev = false
            numbers[0] = ""
        }
        if (numbers[currentNum] == "0" || numbers[currentNum] == "-0") {
            numbers[currentNum] = numbers[currentNum].replacingOccurrences(of: "0", with: "9")
        } else if (numbers[currentNum].replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").count < maxChar) {
            numbers[currentNum] += "9"
        }
        
        result.text = formatNum(n: numbers[currentNum])
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
