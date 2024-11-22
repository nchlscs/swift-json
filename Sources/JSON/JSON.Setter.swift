public extension JSON {

  @dynamicMemberLookup
  struct Setter: Equatable, Sendable {
    var json: JSON
  }
}

public extension JSON.Setter {

  subscript(dynamicMember key: String) -> JSON.Setter {
    get {
      do {
        return try JSON.Setter(json: json[key])
      }
      catch {
        var json = json
        json.storage.node = .object([:])
        return JSON.Setter(json: json)
      }
    }
    set {
      update(value: newValue.json.storage.node, for: .init(stringValue: key))
    }
  }

  subscript(index: Int) -> JSON.Setter {
    get {
      do {
        return try JSON.Setter(json: json[index])
      }
      catch {
        var json = json
        json.storage.node = .array([])
        return JSON.Setter(json: json)
      }
    }
    set {
      update(value: newValue.json.storage.node, for: .init(intValue: index))
    }
  }

  subscript(dynamicMember key: String) -> any JSONConvertible {
    get { "" }
    set { update(value: newValue.jsonNode, for: .init(stringValue: key)) }
  }

  subscript(index: Int) -> any JSONConvertible {
    get { "" }
    set { update(value: newValue.jsonNode, for: .init(intValue: index)) }
  }

  subscript(dynamicMember key: String) -> JSON {
    get {
      do {
        return try json[key]
      }
      catch {
        var json = json
        json.storage.node = .array([])
        return json
      }
    }
    set {
      update(value: newValue.storage.node, for: .init(stringValue: key))
    }
  }

  subscript(index: Int) -> JSON {
    get {
      do {
        return try json[index]
      }
      catch {
        var json = json
        json.storage.node = .object([:])
        return json
      }
    }
    set {
      update(value: newValue.storage.node, for: .init(intValue: index))
    }
  }

  subscript<T: JSONDecodable>(dynamicMember key: String) -> T {
    get throws { try json[key] }
  }

  subscript<T: JSONDecodable>(key: String) -> T {
    get throws { try json[key] }
  }

  subscript<T: JSONDecodable>(index: Int) -> T {
    get throws { try json[index] }
  }

}

private extension JSON.Setter {

  mutating func update(value: JSON.Node, for key: JSON.CodingKey) {
    switch json.storage.node {
    case var .object(object):
      object[key.stringValue] = value
      json.storage.node = .object(object)
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
      json.storage.node = .array(array)
    default:
      let object = [key.stringValue: value]
      json.storage.node = .object(object)
    }
  }
}
