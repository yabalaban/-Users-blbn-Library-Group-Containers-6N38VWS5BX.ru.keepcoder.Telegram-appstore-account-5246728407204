//
//  GridState.swift
//  conway-game-of-life
//
//  Created by Alexander Balaban on 13/10/2022.
//

import MetalKit

struct GridState {
    private(set) var cells: [Bool] = []
    private var indexer: Indexer?
    
    mutating func update(width: Int, height: Int) {
        let count = width * height
        indexer = Indexer(count: count, width: width)
        cells = [Bool].init(repeating: false, count: count)
    }
    
    mutating func next() {
        guard let indexer = indexer else { return }
        
        var new = [Bool].init(cells)
        for i in 0..<cells.count {
            var total = 0
            total += cells[indexer.left(i)] ? 1 : 0
            total += cells[indexer.right(i)] ? 1 : 0
            total += cells[indexer.top(indexer.left(i))] ? 1 : 0
            total += cells[indexer.top(i)] ? 1 : 0
            total += cells[indexer.top(indexer.right(i))] ? 1 : 0
            total += cells[indexer.bottom(indexer.left(i))] ? 1 : 0
            total += cells[indexer.bottom(i)] ? 1 : 0
            total += cells[indexer.bottom(indexer.right(i))] ? 1 : 0

            if new[i] && total >= 2 && total <= 3 {
                new[i] = true
            } else if !new[i] && total == 3 {
                new[i] = true
            } else {
                new[i] = false
            }
        }
        cells = new
    }
}

// MARK: - Objects
extension GridState {
    mutating func spawnPixel(x: Int, y: Int) {
        guard let indexer = indexer else { return }
        let index = indexer.index(x: x, y: y)
        cells[index].toggle()
    }
    
    mutating func spawnGlider(x: Int, y: Int) {
        guard let indexer = indexer else { return }
        let index = indexer.index(x: x, y: y)
        cells[index] = true
        cells[indexer.left(index)] = true
        cells[indexer.left(indexer.left(index))] = true
        cells[indexer.top(index)] = true
        cells[indexer.left(indexer.top(indexer.top(index)))] = true
    }
    
    mutating func spawnToad(x: Int, y: Int) {
        guard let indexer = indexer else { return }
        let index = indexer.index(x: x, y: y)
        cells[index] = true
        cells[indexer.left(index)] = true
        cells[indexer.left(indexer.left(index))] = true
        cells[indexer.top(index)] = true
        cells[indexer.left(indexer.top(index))] = true
        cells[indexer.right(indexer.top(index))] = true
    }
    
    mutating func spawnPulsar(x: Int, y: Int) {
        guard let indexer = indexer else { return }
        let index = indexer.index(x: x, y: y)
        cells[indexer.move(index, diff: (-1, 2))] = true
        cells[indexer.move(index, diff: (-1, 3))] = true
        cells[indexer.move(index, diff: (-1, 4))] = true
        cells[indexer.move(index, diff: (-2, 6))] = true
        cells[indexer.move(index, diff: (-3, 6))] = true
        cells[indexer.move(index, diff: (-4, 6))] = true
        cells[indexer.move(index, diff: (-2, 1))] = true
        cells[indexer.move(index, diff: (-3, 1))] = true
        cells[indexer.move(index, diff: (-4, 1))] = true
        cells[indexer.move(index, diff: (-6, 2))] = true
        cells[indexer.move(index, diff: (-6, 3))] = true
        cells[indexer.move(index, diff: (-6, 4))] = true
        
        cells[indexer.move(index, diff: (-1, -2))] = true
        cells[indexer.move(index, diff: (-1, -3))] = true
        cells[indexer.move(index, diff: (-1, -4))] = true
        cells[indexer.move(index, diff: (-2, -6))] = true
        cells[indexer.move(index, diff: (-3, -6))] = true
        cells[indexer.move(index, diff: (-4, -6))] = true
        cells[indexer.move(index, diff: (-2, -1))] = true
        cells[indexer.move(index, diff: (-3, -1))] = true
        cells[indexer.move(index, diff: (-4, -1))] = true
        cells[indexer.move(index, diff: (-6, -2))] = true
        cells[indexer.move(index, diff: (-6, -3))] = true
        cells[indexer.move(index, diff: (-6, -4))] = true
        
        cells[indexer.move(index, diff: (1, -2))] = true
        cells[indexer.move(index, diff: (1, -3))] = true
        cells[indexer.move(index, diff: (1, -4))] = true
        cells[indexer.move(index, diff: (2, -6))] = true
        cells[indexer.move(index, diff: (3, -6))] = true
        cells[indexer.move(index, diff: (4, -6))] = true
        cells[indexer.move(index, diff: (2, -1))] = true
        cells[indexer.move(index, diff: (3, -1))] = true
        cells[indexer.move(index, diff: (4, -1))] = true
        cells[indexer.move(index, diff: (6, -2))] = true
        cells[indexer.move(index, diff: (6, -3))] = true
        cells[indexer.move(index, diff: (6, -4))] = true
        
        cells[indexer.move(index, diff: (1, 2))] = true
        cells[indexer.move(index, diff: (1, 3))] = true
        cells[indexer.move(index, diff: (1, 4))] = true
        cells[indexer.move(index, diff: (2, 6))] = true
        cells[indexer.move(index, diff: (3, 6))] = true
        cells[indexer.move(index, diff: (4, 6))] = true
        cells[indexer.move(index, diff: (2, 1))] = true
        cells[indexer.move(index, diff: (3, 1))] = true
        cells[indexer.move(index, diff: (4, 1))] = true
        cells[indexer.move(index, diff: (6, 2))] = true
        cells[indexer.move(index, diff: (6, 3))] = true
        cells[indexer.move(index, diff: (6, 4))] = true
    }
    
    mutating func spawnHWSS(x: Int, y: Int) {
        guard let indexer = indexer else { return }
        let index = indexer.index(x: x, y: y)
        cells[indexer.move(index, diff: (0, 0))] = true
        cells[indexer.move(index, diff: (0, 1))] = true
        cells[indexer.move(index, diff: (0, 2))] = true
        cells[indexer.move(index, diff: (-1, 0))] = true
        cells[indexer.move(index, diff: (-1, 1))] = true
        cells[indexer.move(index, diff: (-1, 2))] = true
        cells[indexer.move(index, diff: (-2, 0))] = true
        cells[indexer.move(index, diff: (-2, 1))] = true
        cells[indexer.move(index, diff: (1, 1))] = true
        cells[indexer.move(index, diff: (1, 2))] = true
        cells[indexer.move(index, diff: (1, -1))] = true
        cells[indexer.move(index, diff: (2, 0))] = true
        cells[indexer.move(index, diff: (2, 1))] = true
        cells[indexer.move(index, diff: (2, -1))] = true
        cells[indexer.move(index, diff: (3, 0))] = true
    }
    
    mutating func spawnGliderGun(x: Int, y: Int) {
        guard let indexer = indexer else { return }
        let index = indexer.index(x: x, y: y)
        
        let lsqr = indexer.move(index, diff: (-17, 0))
        cells[lsqr] = true
        cells[indexer.left(lsqr)] = true
        cells[indexer.bottom(lsqr)] = true
        cells[indexer.left(indexer.bottom(lsqr))] = true
        
        let rsqr = indexer.move(index, diff: (16, 1))
        cells[rsqr] = true
        cells[indexer.right(rsqr)] = true
        cells[indexer.top(rsqr)] = true
        cells[indexer.right(indexer.top(rsqr))] = true
        
        let lcl = indexer.move(index, diff: (-1, -1))
        cells[lcl] = true
        cells[indexer.move(lcl, diff: (-1, 0))] = true
        cells[indexer.move(lcl, diff: (-1, 1))] = true
        cells[indexer.move(lcl, diff: (-1, -1))] = true
        cells[indexer.move(lcl, diff: (-2, 2))] = true
        cells[indexer.move(lcl, diff: (-2, -2))] = true
        cells[indexer.move(lcl, diff: (-3, 0))] = true
        cells[indexer.move(lcl, diff: (-4, 3))] = true
        cells[indexer.move(lcl, diff: (-4, -3))] = true
        cells[indexer.move(lcl, diff: (-5, 3))] = true
        cells[indexer.move(lcl, diff: (-5, -3))] = true
        cells[indexer.move(lcl, diff: (-6, 2))] = true
        cells[indexer.move(lcl, diff: (-6, -2))] = true
        cells[indexer.move(lcl, diff: (-7, 1))] = true
        cells[indexer.move(lcl, diff: (-7, -1))] = true
        cells[indexer.move(lcl, diff: (-7, 0))] = true

        let rcl = indexer.move(index, diff: (2, 1))
        cells[rcl] = true
        cells[indexer.move(rcl, diff: (0, 1))] = true
        cells[indexer.move(rcl, diff: (0, -1))] = true
        cells[indexer.move(rcl, diff: (1, 0))] = true
        cells[indexer.move(rcl, diff: (1, 1))] = true
        cells[indexer.move(rcl, diff: (1, -1))] = true
        cells[indexer.move(rcl, diff: (2, 2))] = true
        cells[indexer.move(rcl, diff: (2, -2))] = true
        cells[indexer.move(rcl, diff: (4, 2))] = true
        cells[indexer.move(rcl, diff: (4, -2))] = true
        cells[indexer.move(rcl, diff: (4, 3))] = true
        cells[indexer.move(rcl, diff: (4, -3))] = true
    }
}

// MARK: - Indexer
extension GridState {
    struct Indexer {
        private let count: Int
        private let width: Int
        
        init(count: Int, width: Int) {
            self.count = count
            self.width = width
        }
        
        func index(x: Int, y: Int) -> Int {
            y * width + x
        }
        
        func left(_ i: Int) -> Int {
            let extra = i % width == 0 ? width : 0
            return i - 1 + extra
        }
        
        func right(_ i: Int) -> Int {
            let extra = i % width == width - 1 ? -width : 0
            return i + 1 + extra
        }
        
        func top(_ i: Int) -> Int {
            let extra = i < width ? count : 0
            return i - width + extra
        }
        
        func bottom(_ i: Int) -> Int {
            let extra = i >= count - width ? -count : 0
            return i + width + extra
        }
        
        func move(_ i: Int, diff: (x: Int, y: Int)) -> Int {
            var i = i
            let xfn = diff.x < 0 ? left : right
            i = move(i, fn: xfn, by: abs(diff.x))
            let yfn = diff.y < 0 ? bottom : top
            i = move(i, fn: yfn, by: abs(diff.y))
            return i
        }
        
        func move(_ i: Int, fn: (Int) -> Int, by n: Int) -> Int {
            var n = n
            var i = i
            while n > 0 {
                i = fn(i)
                n -= 1
            }
            return i
        }
    }
}
