//
//  NumberGenerator.swift
//  Table Planner
//
//  Created by Alex Erviti on 8/3/16.
//  Copyright © 2016 Alejandro Erviti. All rights reserved.
//

import Foundation

/* A class used to generate random integers to the given integers, but never repeats. */
class NumberGenerator {
    
    // MARK: Properties
    
    let staticIntArray: [Int];
    var intArray: [Int];
    
    
    init(maxRange: Int) {
        intArray = [Int]();
        for int in 0..<maxRange {
            intArray.append(int);
        }
        staticIntArray = intArray;
    }
    
    
    /* Returns a random integer from 0 to one less than the initialized maxRange. Returns nil if all integers from 0 to maxRange have been generated. */
    func generateNumber() -> Int? {
        if intArray.count == 0 {
            return nil;
        }
        let index = Int(arc4random_uniform(UInt32(intArray.count)));
        let number = intArray.remove(at: index);
        return number;
    }
    
    
    /* Returns the next interger in the intArray. Returns nil if all intergers have already been generated. */
    func generateOrderedNumber() -> Int? {
        if intArray.count == 0 {
            return nil;
        }
        let number = intArray.removeFirst();
        return number;
    }
    
    
    /* Function that resets the generator to return all possible integers again. */
    func reset() {
        intArray = staticIntArray;
    }
    
}
