public final class Equal: BasicTag {
    public enum Error: LeafError {
        case expected2Arguments
    }

    public let name = "equal"

    public func run(arguments: ArgumentList) throws -> Node? {
        guard arguments.count == 2 else { throw Error.expected2Arguments }
        return nil
    }

    public func shouldRender(
        tagTemplate: TagTemplate,
        arguments: ArgumentList,
        value: Node?
    ) -> Bool {
        return fuzzyEquals(
            arguments.first,
            arguments.last
        )
    }
}

fileprivate func fuzzyEquals(_ lhs: Node?, _ rhs: Node?) -> Bool {
    let lhs = lhs ?? .null
    let rhs = rhs ?? .null

    switch lhs.wrapped {
    case let .array(lhs):
        guard let rhs = rhs.array else { return false }
        guard lhs.count == rhs.count else { return false }
        for (l, r) in zip(lhs, rhs) where !fuzzyEquals(Node(l), r) { return false }
        return true
    case let .bool(bool):
        return bool == rhs.bool
    case let .bytes(bytes):
        guard case let .bytes(rhs) = rhs.wrapped else { return false }
        return bytes == rhs
    case .null:
        return rhs.isNull
    case let .number(number):
        switch number {
        case let .double(double):
            return double == rhs.double
        case let .int(int):
            return int == rhs.int
        case let .uint(uint):
            return uint == rhs.uint
        }
    case let .object(lhs):
        guard let rhs = rhs.object else { return false }
        guard lhs.count == rhs.count else { return false }
        for (k, v) in lhs where !fuzzyEquals(Node(v), rhs[k]) { return false }
        return true
    case let .string(string):
        return string == rhs.string
    case let .date(date):
        // FIXME: Add fuzzy date access and equality?
        guard case let .date(right) = rhs.wrapped else { return false }
        return date == right
    }
}
