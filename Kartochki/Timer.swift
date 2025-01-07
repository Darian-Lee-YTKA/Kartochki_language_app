//
//  Timer.swift
//  Kartochki
//
//  Created by Darian Lee on 7/23/24.
//

import Foundation
import Combine


class TimerManager: ObservableObject {
    private var timer: Timer?
    @Published var counter: Int = 0
    var goalTime: Int?
    var ascending: Bool
    var mode: GoalMode
    @Published var hasReachedGoal: Bool = false

    init(goalTime: Int = 15*60, ascending: Bool = false, mode: GoalMode = .Minutes) {
        print("opening timer")
        self.goalTime = goalTime
        self.ascending = ascending
        //resetTimer()
        self.mode = mode
    }
    
    
    func changeSettings(goalTime: Int?, acsending: Bool, mode: GoalMode){
        if mode != .Cards {
            self.ascending = acsending
            if goalTime != nil{
                self.goalTime = goalTime! * 60
            }
            else{
                self.goalTime = nil
            }
        }
        else {
            self.ascending = true // because there is nothing to count down from if the goal refers to cards
        }
        
        self.mode = mode
        
    }
    
    func startTimer() {
        print("start")
        if ascending {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if self.counter == self.goalTime && self.mode == .Minutes {
                    self.hasReachedGoal = true
                }
                    self.counter += 1
                
            }
        }
        else{
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if self.counter > 0 {
                    self.counter -= 1
                } else {
                    self.hasReachedGoal = true
                    self.stopTimer()
                }
            }
        }
    }
    
    func stopTimer() {
        print("stopping timer")
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        print("resetting timer")
        stopTimer()
        if goalTime != nil && ascending == false{
            self.counter = goalTime!
        }
        else{
            self.counter = 0
        }
        startTimer()
    }
}



