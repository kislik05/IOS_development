// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  ->
// Батарея — один физический объект: все дроны и код, который её держит, должны видеть один и тот же заряд, а не копии.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = min(max(charge, 0), 100)
    }

    func level() -> Int {
        return charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, amount <= charge else {
            return false
        }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = min(charge + amount, 100)
    }
}

// Encapsulation proof (оставлено закомментированным):
// let cell = PowerCell(charge: 50)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level
// (раскомментируйте строки, запустите и сверьте текст ошибки с вашей версией Xcode.)

print("--- Level 1 ---")
let testCell = PowerCell(charge: 150)
print("Clamp high: \(testCell.level())")                // 100
print("Clamp low: \(PowerCell(charge: -5).level())")    // 0
print("Spend 30: \(testCell.spend(30)), level \(testCell.level())")    // true, 70
print("Spend 0: \(testCell.spend(0)), level \(testCell.level())")      // false, 70
print("Spend -5: \(testCell.spend(-5)), level \(testCell.level())")    // false, 70
print("Spend 500: \(testCell.spend(500)), level \(testCell.level())")  // false, 70
testCell.recharge(by: 20)
print("Recharge 20: \(testCell.level())")               // 90
testCell.recharge(by: 500)
print("Recharge 500: \(testCell.level())")              // 100
testCell.recharge(by: -10)
print("Recharge -10: \(testCell.level())")              // 100


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  ->
// final запрещает подклассам переопределять runOnce(): ритуал смены (списать энергию, потом работать)
// гарантированно одинаков у всех дронов, а подклассы меняют только powerCost и performTask().
class Drone: Diagnosable, Rechargeable {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }

    var statusLine: String {
        let level = cell.level()
        return "\(id): \(level)% \(level.powerBar)"
    }

    func performTask() -> Int { 0 }

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else {
            return 0
        }
        return performTask()
    }

    // Diagnosable
    var componentID: String { id }
    var statusCode: Int { code(forCharge: cell.level()) }

    // Rechargeable: у класса метод пишется БЕЗ mutating. self — ссылка на объект, и метод
    // меняет сам объект (его батарею), а не переприсваивает self, поэтому mutating не нужен.
    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String {
        return "\(id): seam welded"
    }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String {
        return super.statusLine + " [scanner]"
    }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":
        return WelderDrone(id: id, cell: cell)
    case "scanner":
        return ScannerDrone(id: id, cell: cell)
    case "cargo":
        return CargoDrone(id: id, cell: cell)
    default:
        return nil
    }
}

print("--- Level 2 ---")
var fleet: [Drone] = []
for record in fleetData {
    if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
        fleet.append(drone)
    } else {
        print("Warning: unknown drone kind '\(record.kind)' (\(record.id)), skipped")
    }
}
print("Fleet size: \(fleet.count)")                // 5
for drone in fleet {
    print(drone.statusLine)
}


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    var round = 0
    while round < rounds {
        for drone in fleet {
            total += drone.runOnce()
        }
        round += 1
    }
    return total
}

func countReady(in fleet: [Drone]) -> Int {
    var count = 0
    for drone in fleet {
        if drone.cell.level() >= drone.powerCost {
            count += 1
        }
    }
    return count
}

print("--- Level 3 ---")
print("Ready before shift: \(countReady(in: fleet))")
let A = runShift(fleet, rounds: 3)
print("Work units produced: \(A)")
for drone in fleet {
    print(drone.statusLine)
}

var B = 0
for drone in fleet {
    B += drone.cell.level()
}
let C = countReady(in: fleet)
print("Total charge left (B): \(B)")
print("Drones able to run one more task (C): \(C)")

// слабый дрон просто ничего не производит
let tiredDrone = WelderDrone(id: "W-tired", cell: PowerCell(charge: 5))
print("Tired drone: work \(tiredDrone.runOnce()), charge \(tiredDrone.cell.level())")   // 0, 5
print("Empty fleet: \(runShift([], rounds: 3))")                                        // 0


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Struct, потому что это простое значение без общей идентичности.
struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { code(forCharge: chargeLevel) }

    // mutating обязателен: метод меняет поле struct, а значит меняет self
    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = min(chargeLevel + amount, 100)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

print("--- Level 4 ---")
var demoSensor = sensors[0]
print("Sensor before: \(demoSensor.chargeLevel)")      // 12
demoSensor.recharge(by: 30)
print("Sensor after recharge: \(demoSensor.chargeLevel), original: \(sensors[0].chargeLevel)")   // 42, 12
let demoDrone = WelderDrone(id: "W-demo", cell: PowerCell(charge: 10))
demoDrone.recharge(by: 50)
print("Drone after recharge: \(demoDrone.cell.level())")   // 60

// 4.3
// Элемент массива — протокол, а не класс: SensorModule — struct, и в [Drone] он попасть не может,
// ведь Drone — класс, а структура не может от него наследоваться.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var report = ""
    for component in components {
        report += component.diagnose() + "\n"
    }
    return report
}

var components: [Diagnosable] = []
for drone in fleet {
    components.append(drone)
}
for sensor in sensors {
    components.append(sensor)
}
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + единственное место Health Rule
extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }

    // Health Rule: единственное место во всём файле
    func code(forCharge charge: Int) -> Int {
        if charge < 20 {
            return 2
        } else if charge < 50 {
            return 1
        } else {
            return 0
        }
    }
}

// 5.2 · маяк, который нельзя редактировать
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { code(forCharge: signalStrength) }

    // своё diagnose(), чтобы легаси-оборудование выделялось в логе
    func diagnose() -> String {
        return "[LEGACY] \(name): signal \(signalStrength), code \(statusCode)"
    }
}

print("--- Level 5 ---")
components.append(beacon)
print(diagnosticsReport(components))

var D = 0
for component in components {
    D += component.statusCode
}
print("Sum of status codes (D): \(D)")

// 5.3



// MARK: Level 6 · Incident Reports
// Исходный код отчётов закомментирован в стартовом файле. Ниже разбор и исправленные версии.
// Замечание: по моему анализу, не компилируются Reports 1, 2 и 3, и только Report 4 «компилируется и врёт»
// (в тексте задания сказано 2+2). Объяснения ниже соответствуют фактическому поведению компилятора.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// ---- Report 1 ----
// Ожидание: PatchDrone даёт 30 единиц работы.
// Факт: НЕ КОМПИЛИРУЕТСЯ: "overriding declaration requires an 'override' keyword".
// Правило: performTask() уже есть в Drone, а переопределение метода суперкласса обязано быть помечено override.
// Исправление: override func performTask().
class PatchDrone: Drone {
    override func performTask() -> Int {
        return 30
    }
}

// ---- Report 2 ----
// Ожидание: специальный сварщик, у которого runOnce() возвращает 999.
// Факт: НЕ КОМПИЛИРУЕТСЯ: "inheritance from a final class 'WelderDrone'" и
// "instance method overrides a 'final' instance method".
// Правило: final запрещает наследоваться от класса (WelderDrone) и переопределять метод (runOnce).
// Исправление: наследоваться от Drone и менять только то, что разрешено (performTask), ритуал runOnce остаётся неизменным.
final class HeavyWelder: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 999 }
}

// ---- Report 3 ----
// Ожидание: вызвать weldSeam() у первого элемента массива.
// Факт: НЕ КОМПИЛИРУЕТСЯ: "value of type 'Drone' has no member 'weldSeam'".
// Правило: компилятор проверяет вызовы по СТАТИЧЕСКОМУ типу (Drone), а weldSeam есть только у WelderDrone.
// Исправление: условное приведение as?.
// as? возвращает опционал, потому что во время выполнения элемент может оказаться не WelderDrone, и тогда приведение должно вернуть nil.
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print("--- Report 3 (fixed) ---")
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}
if let scanner = first as? ScannerDrone {
    print(scanner.id)
} else {
    print("first is not a ScannerDrone")
}

// ---- Report 4 ----
// Ожидание: напечатается "thruster T-1".
// Факт: компилируется, но печатает "generic component".
// Правило: label() не входит в требования протокола, он есть только в extension. Такие методы
// вызываются СТАТИЧЕСКИ — по типу переменной (Labelled), а не по реальному типу (Thruster).
// Метод, объявленный в требованиях протокола, вызывается динамически (через witness table) и использует реализацию типа.
// Исправление: одна строка — добавить func label() -> String в сам протокол.
protocol Labelled {
    var componentID: String { get }
    func label() -> String          // <- добавленная строка: теперь это требование протокола
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

print("--- Report 4 (fixed) ---")
let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())              // thruster T-1


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")      // 285-105-3-12


// MARK: Bonus

// 1. Два способа запретить прямое использование Drone

// (а) Ошибка во время выполнения: базовый метод падает с fatalError
class RuntimeAbstractDrone {
    func performTask() -> Int {
        fatalError("RuntimeAbstractDrone is abstract: override performTask()")
    }
}
final class RuntimeWelder: RuntimeAbstractDrone {
    override func performTask() -> Int { 40 }
}
// let bad = RuntimeAbstractDrone().performTask()   // падает ТОЛЬКО при запуске: Fatal error ...

// (б) Ошибка при компиляции: протокол. Создать экземпляр протокола нельзя,
//     а структура без performTask() не скомпилируется — см. редизайн ниже.
// let bad = Worker()   // error: 'Worker' cannot be constructed because it has no accessible initializers

// 2. Редизайн: базовый тип — протокол с protocol extension, WelderUnit — struct
protocol Worker {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int      // обязательное требование — «абстрактный» метод
}

extension Worker {
    func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

struct WelderUnit: Worker {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

struct CargoUnit: Worker {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 20 }
    func performTask() -> Int { 25 }
}

print("--- Bonus ---")
print(RuntimeWelder().performTask())                      // 40
let workers: [Worker] = [
    WelderUnit(id: "WU-1", cell: PowerCell(charge: 60)),
    CargoUnit(id: "CU-1", cell: PowerCell(charge: 10))
]
var unitTotal = 0
for worker in workers {
    unitTotal += worker.runOnce()
}
print("Protocol-based shift: \(unitTotal)")                // 40 (CargoUnit не хватает заряда)

// 3. Сравнение:
// Версия на классе проще для общего состояния и «ритуала» (final runOnce), но абстрактность проверяется только
// в рантайме (fatalError). Версия на протоколе ловит забытый performTask ещё при компиляции и позволяет
// использовать struct, но runOnce из extension может быть «затенён» (как в Report 4), если не сделать
// его требованием протокола. Для этой станции я бы выбрал протокол, потому что дронам нужны разные типы
// (struct и class). Если бы дроны делили изменяемое состояние, я бы взял class: у struct каждая копия
// независима, и общий заряд пришлось бы хранить в отдельном классе (как здесь — PowerCell).


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    mutating означает, что метод может переприсвоить self (заменить само значение).
    У struct self — это само значение, поэтому метод, меняющий поля, обязан быть mutating.
    У класса self — ссылка на объект: метод меняет объект, а ссылка остаётся той же,
    поэтому mutating не нужен и класс удовлетворяет такому требованию обычным методом.

 2. One thing inheritance does that protocols cannot, and one thing protocols do that
    inheritance cannot:
    Наследование: передаёт подклассу хранимые свойства и готовую реализацию (Drone даёт всем
    дронам id и cell). Протокол: объединяет несвязанные типы, включая struct и типы,
    которые нельзя изменить (SensorModule, LegacyBeacon и Drone в одном массиве [Diagnosable]).

 3. What does `final` prevent, and what did it protect in runOnce()?
    final запрещает переопределять метод (или наследоваться от класса). В runOnce() он защитил
    ритуал смены: ни один подкласс не может пропустить списание энергии (как в Report 2,
    где «999» обходил бы проверку заряда). Подклассы меняют только powerCost и performTask().

 4. In Report 4, why did the protocol extension's method win?
    label() не является требованием протокола, а только методом из extension. Такой вызов
    разрешается статически по типу переменной (Labelled) и берёт реализацию из extension.
    Метод, объявленный в протоколе, вызывается динамически через witness table, поэтому побеждает
    реализация конкретного типа (Thruster). Исправление: объявить label() в самом протоколе.
*/
