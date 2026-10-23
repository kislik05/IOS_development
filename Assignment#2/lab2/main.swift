// EASY TASKS

// 1
let fruits: [String] = ["Apple", "Banana", "Orange", "Mango", "Kiwi"]
print("Easy 1 — Third fruit:", fruits[2])

// 2
var favoriteNumbers: Set<Int> = [7, 13, 21]
favoriteNumbers.insert(42)
print("Easy 2 — Updated set:", favoriteNumbers)

// 3
let languages: [String: Int] = [
    "Swift": 2014,
    "Python": 1991,
    "Kotlin": 2011
]
print("Easy 3 — Swift release year:", languages["Swift"] ?? 0)

// 4
var colors: [String] = ["Red", "Green", "Blue", "Yellow"]
colors[1] = "Purple"
print("Easy 4 — Updated array:", colors)

// MEDIUM TASKS

// 1
let setA: Set<Int> = [1, 2, 3, 4]
let setB: Set<Int> = [3, 4, 5, 6]
let intersection = setA.intersection(setB)
print("Medium 1 — Intersection:", intersection)

// 2
var studentScores: [String: Int] = [
    "Anna": 85,
    "Bob": 90,
    "Cara": 78
]
studentScores["Bob"] = 95
print("Medium 2 — Updated dictionary:", studentScores)

// 3
let arrayOne: [String] = ["apple", "banana"]
let arrayTwo: [String] = ["cherry", "date"]
let mergedArray = arrayOne + arrayTwo
print("Medium 3 — Merged array:", mergedArray)

// HARD TASKS

// 1
var populations: [String: Int] = [
    "Kazakhstan": 20_000_000,
    "Russia": 144_000_000,
    "China": 1_400_000_000
]
populations["USA"] = 331_000_000
print("Hard 1 — Updated dictionary:", populations)

// 2
let petsA: Set<String> = ["cat", "dog"]
let petsB: Set<String> = ["dog", "mouse"]
let unionSet = petsA.union(petsB)
let finalSet = unionSet.subtracting(petsB)
print("Hard 2 — Final set:", finalSet)

// 3
let studentGrades: [String: [Int]] = [
    "Anna": [90, 85, 88],
    "Bob":  [70, 75, 80],
    "Cara": [95, 92, 98]
]
// Вторая оценка студента Anna (индекс 1)
let annaSecondGrade = studentGrades["Anna"]?[1] ?? 0
print("Hard 3 — Anna's second grade:", annaSecondGrade)
