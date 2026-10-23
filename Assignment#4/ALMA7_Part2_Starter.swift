// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine

    // switch по self без default: компилятор проверяет, что покрыты все case
    var evacuationPriority: Int {
        switch self {
        case .bridge: return 1
        case .medbay: return 2
        case .lab:    return 3
        case .engine: return 4
        case .cargo:  return 5
        }
    }
}

print("--- 1.1 ---")
for deck in Deck.allCases {
    print("\(deck.rawValue): priority \(deck.evacuationPriority)")
}
print(Deck(rawValue: "lab") as Any)         // Optional(lab)
print(Deck(rawValue: "greenhouse") as Any)  // nil

// 1.2
enum AlarmLevel: Int {
    case green = 0
    case yellow     // 1
    case orange     // 2
    case red        // 3

    static func level(forTotalMass mass: Int) -> AlarmLevel {
        // каждые полные 500 кг = один шаг; всё от 1500 и выше упирается в потолок 3 (red)
        var step = mass / 500
        if step < 0 { step = 0 }
        if step > 3 { step = 3 }
        return AlarmLevel(rawValue: step) ?? .red
    }
}

print("--- 1.2 ---")
print(AlarmLevel.level(forTotalMass: 0))      // green
print(AlarmLevel.level(forTotalMass: 940))    // yellow
print(AlarmLevel.level(forTotalMass: 1500))   // red
print(AlarmLevel.level(forTotalMass: 4000))   // red


// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg: Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    guard let tag = parts.first else { return .unknown(raw: line) }

    switch tag {
    case "crate":
        if parts.count == 3, let id = Int(parts[1]), let mass = Int(parts[2]) {
            return .crate(id: id, massKg: mass)
        }
    case "container":
        if parts.count == 3, let mass = Int(parts[2]) {
            return .container(code: parts[1], massKg: mass)
        }
    case "livestock":
        if parts.count == 4, let count = Int(parts[2]), let unit = Int(parts[3]) {
            return .livestock(species: parts[1], count: count, massPerUnitKg: unit)
        }
    default:
        break
    }
    return .unknown(raw: line)
}

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry {
    case .crate(_, let massKg):
        return massKg
    case .container(_, let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown:
        return 0
    }
}

print("--- 2 ---")
var A = 0
var unknownCount = 0
for line in rawManifest {
    let entry = parseEntry(line)
    A += mass(of: entry)
    if case .unknown = entry {
        unknownCount += 1
    }
    print("\"\(line)\" -> \(entry), mass \(mass(of: entry))")
}
print("Total manifest mass: \(A) kg, unknown lines: \(unknownCount)")   // 1244 kg, 3


// MARK: Level 3 · Crew Snapshots

// 3.1
// Инициализатор не пишем: у структуры Swift сам создаёт memberwise-инициализатор
// init(name:deck:oxygen:). У классов такого нет (см. 4.1).
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int

    mutating func breathe(_ amount: Int) {
        let used = amount > 0 ? amount : 0
        oxygen -= used
        if oxygen < 0 { oxygen = 0 }
    }

    mutating func move(to deck: Deck) {
        self.deck = deck
    }

    // присваиваем self целиком новое значение, а не меняем поля по одному
    mutating func reviveInMedbay() {
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }

    static func rookie(named name: String) -> CrewSnapshot {
        return CrewSnapshot(name: name, deck: .bridge, oxygen: 100)
    }
}

// 3.2
func buildRoster(from data: [(name: String, deck: String, oxygen: Int)]) -> [CrewSnapshot] {
    var result: [CrewSnapshot] = []
    for record in data {
        guard let deck = Deck(rawValue: record.deck) else {
            print("Warning: \(record.name) is on unknown deck '\(record.deck)', skipped")
            continue
        }
        result.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
    }
    return result
}

let crewRoster: [CrewSnapshot] = buildRoster(from: crewData)

print("--- 3.1 / 3.2 ---")
for member in crewRoster {
    print(member)
}
let badRecord: [(name: String, deck: String, oxygen: Int)] = [(name: "Ghost", deck: "attic", oxygen: 1)]
print(buildRoster(from: crewData + badRecord).count)   // предупреждение про Ghost, затем 4

var testMember = CrewSnapshot.rookie(named: "Test")
testMember.breathe(30)
print(testMember)             // oxygen 70
testMember.breathe(500)
print(testMember)             // oxygen 0, не ниже
testMember.move(to: .cargo)
print(testMember)             // deck cargo
testMember.reviveInMedbay()
print(testMember)             // medbay, 100

// 3.3 · Value-semantics demonstration
func drainPlain(_ snapshot: CrewSnapshot) {
    var local = snapshot          // параметр — константа, меняем локальную копию
    local.breathe(10)
    print("  inside drainPlain, local copy oxygen = \(local.oxygen)")
}

func drainInPlace(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(10)
}

print("--- 3.3 ---")
let original = CrewSnapshot(name: "Dana", deck: .lab, oxygen: 48)

// 1. Копия
var copy = original
print("1. Before: original = \(original.oxygen), copy = \(copy.oxygen)")
copy.breathe(20)
print("1. After:  original = \(original.oxygen), copy = \(copy.oxygen)")   // original 48, copy 28

// 2. Обычная функция
var forPlain = original
print("2. Before drainPlain: \(forPlain.oxygen)")
drainPlain(forPlain)
print("2. After drainPlain:  \(forPlain.oxygen)")    // не изменился

// 3. inout
print("3. Before drainInPlace: \(forPlain.oxygen)")
drainInPlace(&forPlain)
print("3. After drainInPlace:  \(forPlain.oxygen)")  // изменился


// MARK: Level 4 · The Teleport Pod

// 4.1
// Обоснование class: у капсулы есть идентичность — это ОДИН физический объект,
// на который ссылаются разные части станции, и его заряд должен быть общим.
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?

    // Инициализатор пишем сами: у struct есть автоматический memberwise init,
    // а у класса Swift его не создаёт (создаётся только пустой init(), и то если
    // у всех свойств есть значения по умолчанию). Здесь у let id значения нет.
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }

    // Бонус: deinit срабатывает, когда исчезает последняя ссылка на объект
    deinit {
        print("deinit: pod \(id) destroyed")
    }

    func load(_ crew: CrewSnapshot) -> Bool {
        guard occupant == nil, chargeLevel >= 20 else {
            return false
        }
        occupant = crew
        return true
    }

    func fire() -> CrewSnapshot? {
        guard let passenger = occupant else {
            return nil      // пусто: заряд не тратим
        }
        chargeLevel -= 20
        occupant = nil
        return passenger
    }
}

func crewMember(named name: String, in list: [CrewSnapshot]) -> CrewSnapshot? {
    for member in list {
        if member.name == name { return member }
    }
    return nil
}

// 4.2 · Charge ledger
print("--- 4.2 ---")
let ledgerPod = TeleportPod(id: "P-1", chargeLevel: 100)
let ledgerNames = ["Timur", "Dana", "Nurlan"]
var stepNumber = 1
for name in ledgerNames {
    if let member = crewMember(named: name, in: crewRoster) {
        let loaded = ledgerPod.load(member)
        let fired = ledgerPod.fire()
        print("Step \(stepNumber): load \(name) = \(loaded), fired \(fired?.name ?? "nobody"), charge = \(ledgerPod.chargeLevel)")
    }
    stepNumber += 1
}
let emptyShot = ledgerPod.fire()
print("Step 4: empty fire -> \(emptyShot as Any), charge = \(ledgerPod.chargeLevel)")

let C = ledgerPod.chargeLevel     // 40
print("C = \(C)")

// проверка отказов load
let weakPod = TeleportPod(id: "P-weak", chargeLevel: 10)
print("Load into weak pod: \(weakPod.load(CrewSnapshot.rookie(named: "X")))")    // false (заряд < 20)
let fullPod = TeleportPod(id: "P-full", chargeLevel: 100)
print("First load: \(fullPod.load(CrewSnapshot.rookie(named: "X")))")            // true
print("Second load: \(fullPod.load(CrewSnapshot.rookie(named: "Y")))")           // false (занята)

// 4.3 · Reference-semantics demonstration
print("--- 4.3 ---")
let podOne = TeleportPod(id: "R-1", chargeLevel: 100)
let podTwo = podOne
podTwo.chargeLevel = 55
print("Pod: podOne = \(podOne.chargeLevel), podTwo = \(podTwo.chargeLevel)")     // 55, 55

var snapOne = CrewSnapshot(name: "Dana", deck: .lab, oxygen: 100)
var snapTwo = snapOne
snapTwo.oxygen = 55
print("Snapshot: snapOne = \(snapOne.oxygen), snapTwo = \(snapTwo.oxygen)")      // 100, 55
snapOne.oxygen = 100

// Правило: присваивание class копирует ССЫЛКУ (оба имени указывают на один объект),
// а присваивание struct копирует САМО ЗНАЧЕНИЕ (получаются независимые копии).


// MARK: Level 5 · Station Systems

// 5.1
// Обоснование class: станция — единственный «живой» объект с общим изменяемым
// состоянием, на который могут ссылаться разные подсистемы.
final class Station {
    // stored (let)
    let callSign: String

    // stored (var) с наблюдателями
    var hullIntegrity: Int = 100 {
        willSet {
            print("Hull integrity: \(hullIntegrity) -> \(newValue)")
        }
        didSet {
            // Присваивание свойства ВНУТРИ его собственного didSet не запускает
            // наблюдатели повторно, поэтому бесконечного цикла нет.
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }

    var oxygenByDeck: [Deck: Int]

    // lazy: замыкание выполнится один раз, при первом обращении
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        var report = "Diagnostics for \(self.callSign):"
        for deck in Deck.allCases {
            report += " \(deck.rawValue)=\(self.oxygenByDeck[deck] ?? 0)"
        }
        report += " hull=\(self.hullIntegrity)"
        return report
    }()

    // computed, read-only (без ключевого слова get)
    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values {
            sum += value
        }
        return sum
    }

    // computed, get + set
    var averageOxygen: Int {
        get {
            guard oxygenByDeck.count > 0 else { return 0 }
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for deck in Array(oxygenByDeck.keys) {
                oxygenByDeck[deck] = newValue
            }
        }
    }

    init(callSign: String, readings: [(deck: String, oxygen: Int)]) {
        self.callSign = callSign
        var dictionary: [Deck: Int] = [:]
        for reading in readings {
            guard let deck = Deck(rawValue: reading.deck) else {
                print("Station: skipping unknown deck '\(reading.deck)'")
                continue
            }
            dictionary[deck] = reading.oxygen
        }
        self.oxygenByDeck = dictionary
    }
}

print("--- 5.1 ---")
let station = Station(callSign: "ALMA-7", readings: deckReadings)
let B = station.averageOxygen        // до любых изменений: 285 / 5 = 57
print("Total oxygen: \(station.totalOxygen), average (B) = \(B)")

print("Before first diagnostics access")
print(station.fullDiagnostics)       // печатает "Running full scan..."
print(station.fullDiagnostics)       // второй раз — сканирования нет, значение уже сохранено

let untouched = Station(callSign: "ALMA-8", readings: deckReadings)
print("Station \(untouched.callSign) created, diagnostics never touched: no scan printed")

station.averageOxygen = 50
print("After setter: average = \(station.averageOxygen), total = \(station.totalOxygen)")   // 50, 250

// 5.2 · The clamp trap
print("--- 5.2 ---")
station.hullIntegrity = 130
print("Hull = \(station.hullIntegrity)")    // 100
station.hullIntegrity = -40
print("Hull = \(station.hullIntegrity)")    // 0
station.hullIntegrity = 55
print("Hull = \(station.hullIntegrity)")    // 55
// Почему нет бесконечного цикла: когда didSet присваивает значение СВОЕМУ ЖЕ свойству,
// Swift не вызывает для этого присваивания observers повторно — иначе clamp зациклился бы.


// MARK: Level 6 · Incident Reports
// Исходный код отчётов закомментирован (в нём есть ошибки), ниже разбор и исправления.

/*
// Report 1
var roster = crewRoster
for var member in roster {
    member.oxygen -= 10
}
print(roster[0].oxygen)

// Report 2
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 0
print(podA.chargeLevel)

// Report 3
struct Logbook {
    var entries: [String] = []
    func add(_ entry: String) {
        entries.append(entry)
    }
}

// Report 4
let snapshot = CrewSnapshot.rookie(named: "Dana")
snapshot.oxygen = 40

let pod = TeleportPod(id: "B", chargeLevel: 50)
pod.chargeLevel = 10
*/

// ---- Report 1 ----
// Ожидание: экипаж потерял по 10 кислорода, roster[0].oxygen станет 52.
// Факт: компилируется, но печатает 62 — ничего не изменилось.
// Правило: CrewSnapshot — struct, значимый тип. `for var member in roster` даёт
// ЛОКАЛЬНУЮ КОПИЮ каждого элемента; изменяется копия, а не массив.
// Исправление: менять элементы массива по индексу.
print("--- Report 1 (fixed) ---")
var fixedRoster = crewRoster
print("Before: \(fixedRoster[0].oxygen)")
for index in 0..<fixedRoster.count {
    fixedRoster[index].oxygen -= 10
}
print("After:  \(fixedRoster[0].oxygen)")       // 52

// ---- Report 2 ----
// Ожидание: podA останется с зарядом 100.
// Факт: печатает 0.
// Правило: TeleportPod — class, ссылочный тип. `let podB = podA` копирует ссылку,
// обе константы указывают на ОДИН объект; изменение через podB видно через podA.
// Исправление: если нужна независимая капсула — создать новый экземпляр.
print("--- Report 2 (fixed) ---")
let fixedPodA = TeleportPod(id: "A", chargeLevel: 100)
let fixedPodB = TeleportPod(id: fixedPodA.id, chargeLevel: fixedPodA.chargeLevel)
fixedPodB.chargeLevel = 0
print("podA = \(fixedPodA.chargeLevel), podB = \(fixedPodB.chargeLevel)")   // 100, 0

// ---- Report 3 ----
// Ожидание: add добавит запись в журнал.
// Факт: НЕ КОМПИЛИРУЕТСЯ. Ошибка: "cannot use mutating member on immutable value: 'self' is immutable".
// Правило: в методе struct self по умолчанию неизменяемый; метод, меняющий свойства,
// должен быть помечен mutating.
// Исправление: mutating func (и вызывать на var).
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
print("--- Report 3 (fixed) ---")
var logbook = Logbook()
logbook.add("Teleporter online")
logbook.add("Hull breach")
print(logbook.entries)

// ---- Report 4 ----
// Ожидание: оба присваивания работают, раз оба значения созданы одинаково.
// Факт: `snapshot.oxygen = 40` — ОШИБКА КОМПИЛЯЦИИ
// ("cannot assign to property: 'snapshot' is a 'let' constant"),
// а `pod.chargeLevel = 10` — компилируется и работает.
// Правило: let замораживает ПЕРЕМЕННУЮ. Для struct значение лежит прямо в переменной,
// поэтому заморожены и все его свойства. Для class в let лежит ССЫЛКА: замороженa
// сама ссылка (нельзя присвоить другой объект), а свойства объекта (var) менять можно.
// Исправление: объявить snapshot через var.
print("--- Report 4 (fixed) ---")
var fixedSnapshot = CrewSnapshot.rookie(named: "Dana")
fixedSnapshot.oxygen = 40
let fixedPod = TeleportPod(id: "B", chargeLevel: 50)
fixedPod.chargeLevel = 10
print("snapshot oxygen = \(fixedSnapshot.oxygen), pod charge = \(fixedPod.chargeLevel)")


// MARK: Level 7 · Sealing the Black Box

// Оригинал (дырявый):
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }

// internal: класс виден во всём модуле, но не за его пределами (уровень по умолчанию, указан явно).
// Обоснование class: журнал один на станцию, его должны разделять все подсистемы.
internal final class FlightRecorder {

    // private: блокирует любой доступ к списку записей снаружи типа — нельзя ни заменить, ни очистить его.
    private var storedEntries: [String] = []

    // private(set): снаружи isSealed можно только ЧИТАТЬ; вернуть его в false снаружи нельзя.
    private(set) var isSealed: Bool = false

    // internal: количество записей доступно для чтения снаружи (только чтение, без setter).
    internal var entryCount: Int {
        return storedEntries.count
    }

    // internal: форматированный транскрипт доступен снаружи (только чтение).
    internal var transcript: String {
        var text = ""
        for line in numberedEntries() {
            text += line + "\n"
        }
        return text
    }

    // internal: добавление — единственный путь записи; после запечатывания запись блокируется.
    internal func add(_ entry: String) {
        guard isSealed == false else {
            print("Recorder is sealed, entry rejected: \(entry)")
            return
        }
        storedEntries.append(entry)
    }

    // internal: запечатать можно, а распечатать — нет (метода unseal не существует).
    internal func seal() {
        isSealed = true
    }

    // fileprivate: виден только внутри этого файла (в т.ч. свободной функции ниже),
    // но недоступен из других файлов. С private функция auditTranscript его бы не увидела.
    fileprivate func numberedEntries() -> [String] {
        var lines: [String] = []
        var number = 1
        for entry in storedEntries {
            lines.append("\(number). \(entry)")
            number += 1
        }
        return lines
    }
}

// Свободная функция вне типа, использует fileprivate-помощник.
func auditTranscript(of recorder: FlightRecorder) -> String {
    let lines = recorder.numberedEntries()
    var text = "AUDIT (\(lines.count) entries, sealed: \(recorder.isSealed))"
    for line in lines {
        text += "\n  " + line
    }
    return text
}

print("--- Level 7 ---")
let blackBox = FlightRecorder()
blackBox.add("Teleporter test started")
blackBox.add("Crew transferred")
print("Entries: \(blackBox.entryCount)")
print(blackBox.transcript)
blackBox.seal()
blackBox.add("Late entry")                 // отклонено
print("Entries after seal: \(blackBox.entryCount), sealed: \(blackBox.isSealed)")
print(auditTranscript(of: blackBox))

// Попытки взломать извне (раскомментируйте, чтобы увидеть ошибки компилятора):
// blackBox.isSealed = false
//   -> error: cannot assign to property: 'isSealed' setter is inaccessible
// blackBox.storedEntries = []
//   -> error: 'storedEntries' is inaccessible due to 'private' protection level
// (точный текст ошибок может немного отличаться в вашей версии Xcode — проверьте и впишите свой.)


// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")      // 1244-57-40-2


// MARK: Bonus

print("--- Bonus ---")
var survivor: TeleportPod?
do {
    let inner = TeleportPod(id: "TMP-1", chargeLevel: 100)
    survivor = inner                                   // вторая ссылка
    print("Inside block, inner = \(inner.id)")
}
print("After block: survivor still alive = \(survivor?.id ?? "none")")   // deinit НЕ сработал
survivor = nil                                         // здесь последняя ссылка исчезает -> deinit
print("After survivor = nil")
// Объяснение: deinit срабатывает, когда счётчик ссылок (ARC) падает до 0. Выход из
// do-блока убрал ссылку inner, но survivor всё ещё держал объект; deinit сработал
// на строке `survivor = nil`, когда исчезла последняя ссылка.

func comparePods(_ a: TeleportPod, _ b: TeleportPod) -> String {
    if a === b {
        return "Same pod (one object, two references)"
    }
    if a.id == b.id && a.chargeLevel == b.chargeLevel {
        return "Two different pods with equal contents"
    }
    return "Different pods"
}
let podX = TeleportPod(id: "X", chargeLevel: 70)
let podXAlias = podX
let podXTwin = TeleportPod(id: "X", chargeLevel: 70)
print(comparePods(podX, podXAlias))   // Same pod
print(comparePods(podX, podXTwin))    // equal contents, different objects
// === нельзя применить к CrewSnapshot: он сравнивает идентичность объектов в памяти,
// а у struct нет идентичности — это значение, копируется при каждом присваивании,
// «тот же самый» экземпляр не существует. === работает только с классами (AnyObject).


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
    У struct Swift автоматически создаёт memberwise-инициализатор по её свойствам
    (CrewSnapshot(name:deck:oxygen:)). У класса такого нет: автоматически даётся
    только пустой init(), и то если у всех свойств есть значения по умолчанию.
    У TeleportPod есть let id без значения, поэтому init нужно писать вручную.

 2. What does mutating actually do to self, and why do classes never need it?
    В методе struct self — неизменяемое значение. mutating превращает self в
    inout: метод может менять свойства или присвоить self новое значение, и
    результат записывается обратно в переменную вызывающего. Поэтому такой
    метод нельзя вызвать у let-значения. В классе self — это ссылка; метод
    меняет объект, на который она указывает, а сама ссылка не меняется,
    поэтому mutating не нужен.

 3. In Report 4, both values are declared with let. Explain precisely what let freezes.
    Для struct значение хранится прямо в константе, поэтому let замораживает
    всё значение целиком, включая var-свойства (snapshot.oxygen = 40 — ошибка).
    Для class в константе лежит только ссылка: let замораживает её (нельзя
    направить на другой объект), но var-свойства самого объекта менять можно
    (pod.chargeLevel = 10 — работает).

 4. Why must a lazy property be var? Give a situation where lazy changes behaviour.
    У lazy-свойства при создании объекта значения ещё нет, оно появляется позже,
    при первом обращении — то есть свойство меняется после init. let должен
    получить значение до конца init, поэтому lazy возможен только с var.
    Меняет поведение, а не только скорость: в fullDiagnostics внутри есть print
    (побочный эффект) — он выполнится один раз и только если свойство
    использовали. Кроме того, значение считается в момент первого обращения
    (например, с тем hullIntegrity, какой был тогда), а не при создании объекта.

 5. private vs fileprivate: concrete case in FlightRecorder.
    Метод numberedEntries() должен вызываться свободной функцией
    auditTranscript(of:), которая лежит ВНЕ типа, но в том же файле. При
    private функция его не увидела бы (private виден только внутри типа и его
    extension в этом файле), а fileprivate разрешает доступ из всего файла,
    не открывая метод другим файлам.

 Bonus. On which line does deinit fire, and why can't === be used on CrewSnapshot?
    deinit срабатывает на строке `survivor = nil`: тогда счётчик ссылок ARC
    становится 0. Выход из do-блока не хватает, потому что вторая ссылка
    (survivor) ещё держит объект. === сравнивает идентичность объектов, а у
    struct идентичности нет — это копируемые значения, работает только для class.
*/
