import Foundation

let firstName: String = "Timofey"
let lastName: String = "Kislov"
var age: Int = 21
let birthYear: Int = 2005
let height: Double = 1.75
let isStudent: Bool = true

var currentYear: Int = 2026
age = currentYear - birthYear

print(firstName + lastName + String(age) + String(height))
var city: String = "Almaty"
var hobby: String = "programming"
var numberOfHobby: Int = 3
let favoriteNumber: Int = 3
var isHobbyCreative: Bool = true

let lifeStory: String = """
My name is \(firstName) \(lastName). I am \(age) years old, born in \(birthYear). \
I live in \(city). I am currently \(isStudent ? "a student" : "not a student"). \
I enjoy \(hobby), which is \(isHobbyCreative ? "a creative" : "not a creative") hobby. \
I have \(numberOfHobby) hobbies in total, and my favorite number is \(favoriteNumber).
"""
let futureGoals: String = """
Right now, I’ve settled on Android and iOS development, I want to decide exactly which direction to take, as I really didn't enjoy web development, and backend work didn't suit me either. So, I’ve moved into mobile development, though I’m also thinking about trying my hand at databases I’ve worked with the Pandas library and enjoyed handling and sorting tables. Ultimately, I believe it’s important to explore various areas to become more versatile in today’s job market.🚀
"""
print(lifeStory, futureGoals)
