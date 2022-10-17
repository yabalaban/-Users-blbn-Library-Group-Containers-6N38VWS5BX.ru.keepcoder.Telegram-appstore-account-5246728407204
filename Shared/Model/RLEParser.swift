//
//  RLEParser.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 17/10/2022.
//

import Foundation

final class RLEParser {
    static func parse(url: URL, order: Int) throws -> PatternModel {
        let data = try Data(contentsOf: url)
        guard let content = String(data: data, encoding: .ascii) else { fatalError() }
        
        var name = url.lastPathComponent
        var points = [(Int, Int)]()
        var skippedHeader = false
        var x = 0
        var y = 0
        var count = 0
        for line in content.split(separator: "\n") {
            if line.starts(with: "#") {
                // Reuse name for UI
                if line.starts(with: "#N") {
                    name = String(line.suffix(from: line.index(line.startIndex, offsetBy: 3)))
                }
            } else {
                if skippedHeader {
                    for ch in line {
                        switch ch {
                        case ch where ch.isNumber:
                            count *= 10
                            count += ch.wholeNumberValue!
                        case "b":
                            x += max(1, count)
                            count = 0
                        case "o":
                            var c = max(1, count)
                            while c > 0 {
                                points.append((x, y))
                                x += 1
                                c -= 1
                            }
                            count = 0
                        case "$":
                            var c = max(1, count)
                            while c > 0 {
                                y += 1
                                c -= 1
                            }
                            x = 0
                            count = 0
                        default:
                            break
                        }
                    }
                } else {
                    skippedHeader = true
                }
            }
        }
        var maxX = 0
        for point in points {
            maxX = max(maxX, point.0)
        }
        let midX = maxX / 2
        let midY = y / 2
        points = points.map({ ($0 - midX, y - $1 - midY) })
        let res: [Int32] = points.reduce(into: []) { $0.append(Int32($1.0)); $0.append(Int32($1.1)) }
        return PatternModel(order: order, name: name, points: res)
    }
}
