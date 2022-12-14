
public protocol Validatable {
    /// Default library functions only throw ``ValidationError``.
    func validate() throws
}

public enum ValidationError: Error {
    case atLeastOneFieldIsRequired(names: [String])
    case tooManyCharacters(name: String, max: Int)
    case tooManyElements(name: String, max: Int)
    case containsProhibitedValues(name: String, reason: String, valuesRepresentation: String)
    case hasPrecondition(name: String, reason: String)
    case cantBeEmpty(name: String)
}

extension Validatable {
    
    @inlinable
    func validateAtLeastOneIsNotEmpty(
        _ isEmpties: Bool?...,
        names: String...
    ) throws {
        guard isEmpties.contains(where: { $0 == false || $0 == nil }) else {
            throw ValidationError.atLeastOneFieldIsRequired(names: names)
        }
    }
    
    @inlinable
    func validateCharacterCountDoesNotExceed(_ value: String?, max: Int, name: String) throws {
        guard value?.unicodeScalars.count ?? 0 <= max else {
            throw ValidationError.tooManyCharacters(name: name, max: max)
        }
    }
    
    @inlinable
    func validateCombinedCharacterCountDoesNotExceed(
        _ count: Int?,
        max: Int,
        names: String...
    ) throws {
        guard count ?? 0 <= max else {
            throw ValidationError.tooManyCharacters(name: names.joined(separator: "+"), max: max)
        }
    }
    
    @inlinable
    func validateElementCountDoesNotExceed<T>(_ array: Array<T>?, max: Int, name: String) throws {
        guard array?.count ?? 0 <= max else {
            throw ValidationError.tooManyElements(name: name, max: max)
        }
    }
    
    @inlinable
    func validateOnlyContains<C: Collection>(
        _ values: C?,
        name: String,
        reason: String,
        where block: (C.Element) -> Bool
    ) throws {
        if values?.first(where: { !block($0) }) != nil {
            throw ValidationError.containsProhibitedValues(
                name: name,
                reason: reason,
                valuesRepresentation: "\(values!)"
            )
        }
    }
    
    @inlinable
    func validateHasPrecondition(
        condition: Bool,
        allowedIf: Bool,
        name: String,
        reason: String
    ) throws {
        if condition {
            if !allowedIf {
                throw ValidationError.hasPrecondition(
                    name: name,
                    reason: reason
                )
            }
        }
    }
    
    @inlinable
    func validateAssertIsNotEmpty(_ isNotEmpty: Bool, name: String) throws {
        if !isNotEmpty {
            throw ValidationError.cantBeEmpty(name: name)
        }
    }
}
