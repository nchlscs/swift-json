public extension JSON {

  @dynamicMemberLookup
  struct Setter: Equatable, Sendable {
    var node: Node
  }
}

public extension JSON.Setter {

  subscript(dynamicMember key: String) -> JSON.Setter {
    get {
      do {
        return try JSON.Setter(node: JSON(node)[key])
      }
      catch {
        return JSON.Setter(node: .object([:]))
      }
    }
    set {
      update(value: newValue.node, for: .init(stringValue: key))
    }
  }

  subscript(index: Int) -> JSON.Setter {
    get {
      do {
        return try JSON.Setter(node: JSON(node)[index])
      }
      catch {
        return JSON.Setter(node: .array([]))
      }
    }
    set {
      update(value: newValue.node, for: .init(intValue: index))
    }
  }

  subscript(dynamicMember key: String) -> any JSONConvertible {
    get { node }
    set { update(value: newValue.jsonNode, for: .init(stringValue: key)) }
  }

  subscript(dynamicMember key: String) -> JSON {
    get { JSON(node) }
    set { update(value: newValue.storage.node, for: .init(stringValue: key)) }
  }

  subscript(index: Int) -> any JSONConvertible {
    get { node }
    set { update(value: newValue.jsonNode, for: .init(intValue: index)) }
  }
}

private extension JSON.Setter {

  mutating func update(value: JSON.Node, for key: JSON.CodingKey) {
    switch node {
    case var .object(object):
      object[key.stringValue] = value
      node = .object(object)
    case var .array(array):
      guard let index = key.intValue, index >= 0, index <= array.count else {
        fallthrough
      }
      if index < array.count {
        array[index] = value
      }
      else {
        array.append(value)
      }
      node = .array(array)
    default:
      let object = [key.stringValue: value]
      node = .object(object)
    }
  }
}
