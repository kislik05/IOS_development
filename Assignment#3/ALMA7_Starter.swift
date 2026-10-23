// =============================================================
//  Станция ALMA-7: Протокол спасательной операции
//  Разработка мобильных приложений для iOS · Модуль 3 · Лабораторное задание
//
//  Инструкция по использованию:
//   • Xcode: «Файл» → «Создать» → «Playground» → «Пустой», замените всё
//     содержимое на содержимое этого файла.
//   • Терминал: swift ALMA7_Starter.swift
//
//  Правила:
//   • НЕ изменяйте раздел «Исходный код».
//   • Использование `!` (принудительное развертывание) запрещено: за каждый случай вычитается −0,5 балла.
//   • Не используйте map / filter / reduce / compactMap.
//   • Используйте точные названия функций из PDF-файла с заданием.
// =============================================================
typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= КОНЕЦ ИСХОДНОГО КОДА =================


// MARK: - =================== ВАШЕ РЕШЕНИЕ ===================


// MARK: Уровень 1 · Декодирование телеметрических данных

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let parts = splitOnce(raw, by: ":"),
          !parts.0.isEmpty,
          let value = Int(parts.1),
          value >= 0 || parts.0 == "TEMP" else {
        return nil
    }
    return (sensor: parts.0, value: value)
}

print("--- 1.1 ---")
print(parseReading("O2:87") as Any)     // Optional((sensor: "O2", value: 87))
print(parseReading("TEMP:-12") as Any)  // Optional((sensor: "TEMP", value: -12))
print(parseReading("RAD:-1") as Any)    // nil
print(parseReading(":55") as Any)       // nil
print(parseReading("O2:9x") as Any)     // nil
print(parseReading("hello") as Any)     // nil

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var valid: [Reading] = []
    var invalidCount = 0
    for line in lines {
        if let reading = parseReading(line) {
            valid.append(reading)
        } else {
            invalidCount += 1
        }
    }
    return (valid: valid, invalidCount: invalidCount)
}

let parsed = parseLog(rawLog)
let A = parsed.invalidCount
print("--- 1.2 ---")
print("Valid: \(parsed.valid.count), invalid: \(A)")
print(parseLog([]))
print(parseLog(["O2:1", "bad"]))


// MARK: Уровень 2 · Анализ

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var result: [Reading] = []
    for reading in readings {
        if isIncluded(reading) {
            result.append(reading)
        }
    }
    return result
}

func values(of readings: [Reading]) -> [Int] {
    var result: [Int] = []
    for reading in readings {
        result.append(reading.value)
    }
    return result
}

let o2Readings = select(parsed.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)
print("--- 2.1 ---")
print("O2 values: \(o2Values)")                                   // [87, 64, 71, 90]
print("Only TEMP: \(values(of: select(parsed.valid) { $0.sensor == "TEMP" }))")

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard let first = values.first else { return nil }
    var minValue = first
    var maxValue = first
    var sum = 0
    for v in values {
        if v < minValue { minValue = v }
        if v > maxValue { maxValue = v }
        sum += v
    }
    return (min: minValue, max: maxValue, average: Double(sum) / Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print("--- 2.2 ---")
print(stats(3, 8, 1) as Any)   // (min: 1, max: 8, average: 4.0)
print(stats() as Any)          // nil
print(stats(of: []) as Any)    // nil
print(stats(of: o2Values) as Any)

var B = 0
if let o2Stats = stats(of: o2Values) {
    B = Int(o2Stats.average)   // 78
}
print("B = \(B)")

// 2.3 · Лестница замыканий
let sorted1 = parsed.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})
let sorted2 = parsed.valid.sorted(by: { a, b in
    return a.value > b.value
})
let sorted3 = parsed.valid.sorted(by: { a, b in a.value > b.value })
let sorted4 = parsed.valid.sorted(by: { $0.value > $1.value })
let sorted5 = parsed.valid.sorted { $0.value > $1.value }

func sameReadings(_ x: [Reading], _ y: [Reading]) -> Bool {
    if x.count != y.count { return false }
    var i = 0
    while i < x.count {
        if x[i].sensor != y[i].sensor || x[i].value != y[i].value { return false }
        i += 1
    }
    return true
}

print("--- 2.3 ---")
print(values(of: sorted5))
print("1==2: \(sameReadings(sorted1, sorted2)), 2==3: \(sameReadings(sorted2, sorted3)), 3==4: \(sameReadings(sorted3, sorted4)), 4==5: \(sameReadings(sorted4, sorted5))")


// MARK: Уровень 3 · Стабилизация температуры

// 3.1
func heatUp(_ t: Int) -> Int { return t + 5 }
func coolDown(_ t: Int) -> Int { return t - 3 }
func hold(_ t: Int) -> Int { return t }

func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp < 18 {
        return heatUp
    } else if temp > 24 {
        return coolDown
    } else {
        return hold
    }
}

print("--- 3.1 ---")
print(chooseProtocol(for: 10)(10))   // 15
print(chooseProtocol(for: 30)(30))   // 27
print(chooseProtocol(for: 20)(20))   // 20

// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var temp = start
    var steps = 0
    while (temp < 18 || temp > 24) && steps < maxSteps {
        let action = chooseProtocol(for: temp)
        temp = action(temp)
        steps += 1
    }
    return (finalTemp: temp, steps: steps, isStable: temp >= 18 && temp <= 24)
}

print("--- 3.2 ---")
print(runUntilStable(from: 31))                    // (22, 3, true)
print(runUntilStable(from: -100, maxSteps: 5))     // (-75, 5, false)
print(runUntilStable(from: 20))                    // (20, 0, true)

let temps = values(of: select(parsed.valid) { $0.sensor == "TEMP" })
var C = 0
if let tempStats = stats(of: temps) {
    C = runUntilStable(from: tempStats.min).steps
}
print("Lowest temp: \(stats(of: temps)?.min as Any), C = \(C)")


// MARK: Уровень 4 · Экипаж

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print("--- 4.1 ---")
for member in crew {
    print("\(member.name): \(oxygenLevel(of: member) as Any)")
}

// 4.2
func status(of member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        let place = member.module?.name ?? "open space"
        return "\(member.name): no data (\(place))"
    }
    return level < 20 ? "\(member.name): \(level)% CRITICAL" : "\(member.name): \(level)% OK"
}

print("--- 4.2 ---")
for member in crew {
    print(status(of: member))
}

// 4.3
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    if amount < 0 { return 0 }
    var moved = amount
    if moved > source { moved = source }
    let freeSpace = 100 - target
    if moved > freeSpace { moved = freeSpace }
    if moved < 0 { return 0 }
    source -= moved
    target += moved
    return moved
}

print("--- 4.3 ---")
var testA = 50
var testB = 90
print(transferOxygen(from: &testA, to: &testB, amount: 30))  // 10 (в приёмнике место только на 10)
print(testA, testB)                                          // 40 100
print(transferOxygen(from: &testA, to: &testB, amount: -5))  // 0

var D = 0
if let labTank = lab.oxygenTank, let habTank = hab.oxygenTank {
    transferOxygen(from: &labTank.level, to: &habTank.level, amount: 30)
    D = habTank.level   // 42
}
print("Lab: \(lab.oxygenTank?.level as Any), Hab: \(hab.oxygenTank?.level as Any), D = \(D)")

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var found: [CrewMember] = []
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        found.append(member)
    }
    let ordered = found.sorted { $0.priority < $1.priority }
    var result: [String] = []
    for member in ordered {
        result.append(member.name)
    }
    return result
}

print("--- 4.4 ---")
print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))  // ["Aigerim", "Timur", "Dana"]
print(evacuationOrder("Nurlan", "Dana", roster: roster))                     // ["Nurlan", "Dana"]


// MARK: Уровень 5 · Журнал саботажника

/*
Оригинальный код саботажника (закомментирован, т.к. использует !):

func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}

ПРОБЛЕМЫ:
reportOxygen:
 1. member.module! — если у члена экипажа нет модуля (Nurlan, открытый космос),
    module == nil и программа падает (crash).
 2. oxygenTank! — если в модуле нет бака (Dana, Dock), tank == nil и программа падает.
 Исправление: опциональная цепочка (oxygenLevel) + ?? / guard let.

firstCritical:
 3. oxygenLevel(of:)! — для Dana или Nurlan вернётся nil, и ! вызовет crash.
    На стартовых данных упадёт уже на Dana.
 4. Логическая ошибка: нет break/return внутри цикла, поэтому result перезаписывается
    каждым следующим критическим членом экипажа. Функция возвращает ПОСЛЕДНЕГО
    критического, а не ПЕРВОГО. Падения нет, ответ тихо неверный.
    На стартовых данных не видно: критический только Aigerim (12%).
 5. result! в конце — если критических нет (все >= 20 или нет данных),
    result == nil и программа падает.
 6. Тип возврата String не позволяет сказать «критических нет» — нужен String?.
*/

func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

print("--- 5 ---")
for member in crew {
    print(reportOxygen(for: member))   // не падает на Dana и Nurlan
}
print(firstCritical(in: crew) as Any)  // Optional("Aigerim")

// Тест логической ошибки: два критических члена экипажа, нужен ПЕРВЫЙ
let lowTank1 = Tank(level: 5)
let lowTank2 = Tank(level: 10)
let testCrew = [
    CrewMember(name: "First",  role: "Test", priority: 1, module: Module(name: "M1", oxygenTank: lowTank1)),
    CrewMember(name: "Second", role: "Test", priority: 2, module: Module(name: "M2", oxygenTank: lowTank2))
]
print(firstCritical(in: testCrew) as Any)                 // Optional("First") (у саботажника было бы "Second")
print(firstCritical(in: testCrew) == "First")             // true
print(firstCritical(in: []) as Any)                       // nil, без падения
let safeCrew = [CrewMember(name: "Safe", role: "Test", priority: 1, module: Module(name: "M3", oxygenTank: Tank(level: 80)))]
print(firstCritical(in: safeCrew) as Any)                 // nil


// MARK: Финал · Код запуска

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")   // 6-78-6-42


// MARK: Бонус

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}

print("--- Bonus ---")
let alarm = makeAlarm(threshold: 20)
print(alarm(12))   // Alarm #1, true
print(alarm(40))   // false
print(alarm(5))    // Alarm #2, true


// MARK: - ================= ВОПРОСЫ ПО ЗАЩИТЕ =================
/*
 1. guard let vs if let: за пределами синтаксиса:
    - guard let разворачивает значение в ТОЙ ЖЕ области видимости: после guard
      переменная доступна до конца функции. С if let она живёт только внутри { }.
    - guard заставляет в else выйти (return/continue/break/throw), поэтому «плохой»
      случай обрабатывается сразу, а основной код не уходит вправо.
    Пример, где if let хуже (пирамида вложенности):
      if let parts = splitOnce(raw, by: ":") {
          if !parts.0.isEmpty {
              if let value = Int(parts.1) {
                  // ... основная логика где-то глубоко
              }
          }
      }
    С guard let всё в одной плоской цепочке, а основная логика идёт ниже без отступов.

 2. Почему нельзя передать [Int] в stats(_ values: Int...)?
    Variadic-параметр принимает ОТДЕЛЬНЫЕ значения через запятую: stats(1, 2, 3).
    Массив — это один аргумент типа [Int], а не несколько Int, поэтому Swift не
    «раскрывает» его автоматически (как * в Python). Внутри функции values уже
    массив [Int], но снаружи нужно передавать элементы по отдельности.
    Для массива есть stats(of: someArray).

 3. Почему transferOxygen(from: &x, to: &x, amount: 5) не компилируется?
    Swift запрещает одновременный доступ к одной переменной через два inout
    (нарушение эксклюзивного доступа, exclusive access). Это защищает от бага,
    когда source и target — одна и та же переменная: изменения перезаписывали бы
    друг друга и результат был бы непредсказуем (кислород «перекладывается»
    сам в себя, баланс ломается).

 4. Почему oxygenLevel(of: dana) ?? "no data" не компилируется?
    oxygenLevel возвращает Int?, а "no data" — это String. Оператор ?? требует,
    чтобы значение по умолчанию было того же типа, что и обёрнутое значение (Int).
    Нужно или Int по умолчанию (oxygenLevel(of: dana) ?? 0), или развернуть
    опционал через if let / guard let и вернуть строку в ветке else.

 5. Полный тип chooseProtocol и как его читать:
    (Int) -> (Int) -> Int   — но с учётом label: (for: Int) -> ((Int) -> Int)
    Читается: «функция, которая принимает Int (температуру) и возвращает
    функцию, принимающую Int и возвращающую Int». Стрелка -> правоассоциативна:
    A -> B -> C это A -> (B -> C). Вызов chooseProtocol(for: 10)(10):
    первые скобки выбирают протокол, вторые применяют его к температуре.

 Бонус. Где хранится счётчик сигнала тревоги после возврата makeAlarm?
    Переменная count захватывается (capture) замыканием. Swift перемещает её
    из стека в кучу (heap) в специальный «ящик», на который замыкание держит
    ссылку. Пока замыкание (alarm) существует, этот ящик живёт, поэтому count
    сохраняется между вызовами, хотя makeAlarm давно завершилась.
*/
