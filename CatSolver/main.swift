//
//  main.swift
//  CatSolver
//
//  Created by Michael Emery on 7/22/14.
//  Copyright (c) 2014 Michael Emery. All rights reserved.
//

import Foundation
// Playground - noun: a place where people can play

import Cocoa

let BOARD_WIDTH = 5;
let BOARD_HEIGHT = 5;

enum TileState {
    case Empty,
    White,
    Black
    
    func toStr() -> String {
        switch self {
        case .Empty:
            return "-"
        case .Black:
            return "B"
        case .White:
            return "W"
        }
    }
}

enum Direction: Int {
    case Forward = 1,
    Stationary = 0,
    Backward = -1
}

struct Move {
    var x: Direction
    var y: Direction
    
    func toStr() -> String {
        return "(\(x.toRaw()), \(y.toRaw()))"
    }
}

struct Position {
    var row: Int
    var col: Int
    
    func toStr() -> String {
        return "(\(col), \(row))"
    }
}

@infix func + (position: Position, move: Move) -> Position {
    return Position(row: position.row + move.y.toRaw(), col: position.col + move.x.toRaw())
}

let potentialMoves = [
    Move(x: .Backward, y: .Backward),
    Move(x: .Stationary, y: .Backward),
    Move(x: .Forward, y: .Backward),
    
    Move(x: .Backward, y: .Stationary),
    Move(x: .Forward, y: .Stationary),
    
    Move(x: .Backward, y: .Forward),
    Move(x: .Stationary, y: .Forward),
    Move(x: .Forward, y: .Forward)
]

class Board {
    let tiles : TileState[][];
    let blackPosition: Position;
    
    init() {
        tiles = [
            [.Empty, .Empty, .Empty, .Empty, .Empty],
            [.Empty, .White, .White, .White, .Empty],
            [.Empty, .White, .Black, .White, .Empty],
            [.Empty, .White, .White, .White, .Empty],
            [.Empty, .Empty, .Empty, .Empty, .Empty]
        ]
        blackPosition = Position(row: 2, col: 2)
    }
    
    init(tiles: TileState[][], blackPosition: Position) {
        self.tiles = tiles.copy()
        self.blackPosition = blackPosition
    }
    
    func tileCopy() -> TileState[][] {
        var copy = TileState[][](count: tiles.count, repeatedValue: TileState[]());
        
        for rowIdx in 0..tiles.count {
            copy[rowIdx] = tiles[rowIdx].copy()
        }
        
        return copy;
    }
    
    func move(current: Position, move: Move) -> Board? {
        
        let step1 = current + move
        let step2 = step1 + move
        
        var result: Board?
        
        var newPos = blackPosition
        
        if(canMove(current, move: move)) {
            
            if(isBlack(current)) {
                newPos = step2
            }
            
            var newTiles = self.tileCopy()
            newTiles[step2.row][step2.col] = newTiles[current.row][current.col]
            newTiles[current.row][current.col] = .Empty
            newTiles[step1.row][step1.col] = .Empty
            
            result = Board(tiles: newTiles, blackPosition: newPos);
        }
        
        return result
    }
    
    func buildMoves() -> Board[] {
        
        var moves = Board[]();
        
        if(self.hasPotential()) {
            for rowIdx in 0..tiles.count {
                for colIdx in 0..tiles[rowIdx].count {
                    for candidate in potentialMoves {
                        if let result = move(Position(row: rowIdx, col: colIdx), move: candidate) {
                            moves.append(result);
                        }
                    }
                }
            }
        }
        return moves
    }
    
    func isWhite(pos: Position) -> Bool {
        return isOnBoard(pos) && (tiles[pos.row][pos.col] == .White)
    }
    
    func isBlack(pos: Position) -> Bool {
        return isOnBoard(pos) && (tiles[pos.row][pos.col] == .Black)
    }
    
    func isEmpty(pos: Position) -> Bool {
        return isOnBoard(pos) && (tiles[pos.row][pos.col] == .Empty)
    }
    
    func isOnBoard(pos: Position) -> Bool {
        return pos.row < tiles.count && pos.col < tiles[0].count && pos.row >= 0 && pos.col >= 0;
    }
    
    func canMove(current: Position, move: Move) -> Bool {
        
        let step1 = current + move
        let step2 = step1 + move
        
        if(isWhite(current) || isBlack(current)) {
            return isWhite(step1) && isEmpty(step2);
        }
        else {
            return false
        }
        
    }
    
    func whiteCount() -> Int {
        var whiteCount = 0
        for i in 0..tiles.count {
            let row = tiles[i];
            for j in 0..row.count {
                if(isWhite(Position(row: i, col: j))) {
                    whiteCount++
                }
            }
        }
        
        return whiteCount;
    }
    
    func isVictory() -> Bool {
        return isBlack(Position(row: 2, col: 2)) && whiteCount() == 0
    }
    
    func toStr() -> String {
        var str = ""
        for row in tiles {
            for col in row {
                str += col.toStr()
            }
            str += "\n"
        }
        
        return str
    }
    
    func solve() {
        solveImpl(Board[](), current: self)
    }
    
    func solveImpl(let moveSet: Board[], current: Board) {
        var copy = moveSet.copy()
        copy.append(current)
        var newMoves = current.buildMoves()
        
        if(current.isVictory()) {
            println("SOLUTION")
            printMoves(copy)
            exit(0);
        }
        else if newMoves.count > 0 {
            
            for move in newMoves {
                
                printMoves(copy + [move])
                
                solveImpl(copy, current: move)
            }
        }
    }
    
    func printMoves(moves: Board[]) {
        var strs = String[]()
        
        var rowCount = self.tiles.count;
        var colCount = 0
        
        for rowIdx in 0..rowCount {
            var str = ""
            for board in moves {
                var row = board.tiles[rowIdx]
                str += "|"
                
                for col in row {
                    str += col.toStr()
                    colCount = rowIdx * row.count
                }
                
                str += "|"
            }
            strs.append(str)
        }
        
        for str in strs {
            println(str)
        }
    }
    
    func hasPotential() -> Bool{
        var blackMoves = false
        
        for move in potentialMoves {
            if(canMove(blackPosition, move: move)) {
                blackMoves = true
                break
            }
        }
        
        return blackMoves
    }
}

let start = Board()
start.solve()
