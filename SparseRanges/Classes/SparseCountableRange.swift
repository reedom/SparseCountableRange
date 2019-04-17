/// A collection of CountableRange objects that expresses a sparsed range.
///
/// var r = SparseCountableRange<Int>()
/// r.add(10..<20)  // [10..<20]          adds a range.
/// r.add(30..<40)  // [10..<20, 30..<40] adds one more range, now it contains two ranges.
/// r.add(35..<50)  // [10..<20, 30..<50] adds another but it will be merged with the second one.
/// r.add(15..<35)  // [10..<50]          adds another and it will merge all because it overlaps with them.
///
public class SparseCountableRange<Bound> where Bound : Strideable, Bound.Stride : SignedInteger {
  private typealias klass = SparseCountableRange<Bound>

  private var _ranges: [CountableRange<Bound>]

  /// A raw collection of stored ranges.
  public var ranges: [CountableRange<Bound>] {
    get { return _ranges }
  }

  /// Create an instance with an empty collection.
  public init() {
    _ranges = [CountableRange<Bound>]()
  }

  /// Create an instance with the specified collection.
  public init(initial: [CountableRange<Bound>]) {
    self._ranges = initial
    klass.normalize(ranges: &self._ranges)
  }

  /// Create an instance with the specified collection.
  ///
  /// It expects that `sortedRanges` has been sorted and normalized
  /// to be conformant the internal use so that it can omit the
  /// nomalization process.
  public init(sortedRanges: [CountableRange<Bound>]) {
    self._ranges = sortedRanges
  }

  /// The number of ranges in the array.
  ///
  /// let r = SparseCountableRange<Int>(initial: [10..<20, 30..<40])
  /// r.countOfRanges  // 2
  public var countOfRanges: Int {
    get { return _ranges.count }
  }

  /// The number of elements in total.
  ///
  /// To check whether a collection is empty, use its `isEmpty` property
  /// instead of comparing `count` to zero. Calculating `countOfElements`
  /// can be an O(*n*) operation.
  ///
  /// let r = SparseCountableRange<Int>(initial: [10..<20, 30..<40])
  /// countOfElements  // 20
  //
  /// - Complexity: O(*n*) where *n* is the count of the sparse ranges.
  public var countOfElements: Int {
    get { return _ranges.reduce(0, { $0 + $1.count }) }
  }

  /// A Boolean value indicating whether the collection is empty.
  ///
  /// When you need to check whether your collection is empty, use the
  /// `isEmpty` property instead of checking that either of `countOfRanges`
  /// or `countOfElements` properties are equal to zero.
  ///
  /// - Complexity: O(1)
  public var isEmpty: Bool {
    get { return _ranges.isEmpty }
  }

  /// Inspect the `subject` and extract zero or more ranges which the correction
  /// does not contain.
  ///
  /// let r = SparseCountableRange<Int>(initial: [10..<20, 30..<40])
  /// r.gaps(1..<5)  // [1..<5]
  /// r.gaps(1..<50) // [1..<5, 20..<30, 40..<50]
  ///
  /// - TODO: rename to more accurate one.
  public func gaps(_ subject: CountableRange<Bound>) -> [CountableRange<Bound>]? {
    var i = 0
    var result: [CountableRange<Bound>]?
    var range = subject
    while i < _ranges.endIndex {
      if _ranges[i].upperBound <= range.lowerBound {
        // `range` comes after `i`
        // i:   |----|
        // new:      |----|
        i += 1
        continue
      }

      if range.upperBound <= _ranges[i].lowerBound {
        // `range` comes before `i`
        // i:        |----|
        // new: |----|
        return result == nil ? [range] : result! + [range]
      }

      if _ranges[i].lowerBound <= range.lowerBound && range.upperBound <= _ranges[i].upperBound {
        // `i` contains entire `range`
        // i:   |----|
        // new: |----|
        return result
      }

      if range.lowerBound <= _ranges[i].lowerBound {
        if result == nil {
          result = []
        }
        result!.append(range.lowerBound ..< _ranges[i].lowerBound)

        if range.upperBound <= _ranges[i].upperBound {
          // `range` overlaps at the head of `i`...
          // i:     |----|
          // new: |----|
          return result
        } else {
          // `range` contains  `i`...
          // i:     |----|
          // new: |-------|
          range = _ranges[i].upperBound ..< range.upperBound
          i += 1
          continue
        }
      } else {
        // `range` overlaps at the tail of `i`...
        // i:   |----|
        // new:    |----|
        range = _ranges[i].upperBound ..< range.upperBound
        i += 1
        continue
      }
    }

    // `range` is not found
    return result == nil ? [range] : result! + [range]
  }

  /// Add a range to the collection.
  /// If the range overlaps with any ranges in the collection,
  /// a merging will take place.
  ///
  /// var r = SparseCountableRange<Int>(initial: [10..<20, 30..<40])
  /// r.add(1..<5)  // r.ranges: [1..<5, 10..<20, 30..<40]
  /// r.add(2..<15) // r.ranges: [1..<20, 30..<40]
  ///
  /// - Returns: `true` if the `range` has modified the collection.
  /// `false` if the `range` has not modified the collection. Possibly
  ///  the `range` was empty or the collection has already contained it.
  public func add(_ range: CountableRange<Bound>) -> Bool {
    guard !range.isEmpty else { return false }

    var i = 0
    while i < _ranges.endIndex {
      if _ranges[i].upperBound < range.lowerBound {
        // `range` comes far after `i`
        // i:   |----|
        // new:          |----|
        i += 1
        continue
      }

      if _ranges[i].lowerBound <= range.lowerBound && range.upperBound <= _ranges[i].upperBound {
        // `i` contains entire `range`
        // i:   |----|
        // new: |----|
        return false
      }

      if range.upperBound < _ranges[i].lowerBound {
        // `range` comes far before `i`
        // i:            |----|
        // new: |----|
        _ranges.insert(range, at: i)
        return true
      }

      if range.lowerBound <= _ranges[i].lowerBound {
        if range.upperBound <= _ranges[i].upperBound {
          // `range`'s head and `i` overlapps
          // i:     |----|
          // new: |----|
          _ranges[i] = range.lowerBound ..< _ranges[i].upperBound
        } else {
          // `range` contains  `i`...
          // i:     |----|
          // new: |-------|
          _ranges[i] = range
        }
        klass.mergeRanges(sortedRanges: &_ranges, startAt: i, partial: true)
        return true
      } else {
        // `range`'s tail and `i` overlapps
        // i:   |----|
        // new:    |----|
        _ranges[i] = _ranges[i].lowerBound ..< range.upperBound
        klass.mergeRanges(sortedRanges: &_ranges, startAt: i, partial: true)
        return true
      }
    }

    // `range` is not found
    _ranges.append(range)
    return true
  }

  /// Normailze the input array contents.
  private class func normalize(ranges: inout [CountableRange<Bound>]) {
    guard !ranges.isEmpty else { return }

    ranges.removeAll(where: { $0.isEmpty })
    ranges.sort { $0.lowerBound < $1.lowerBound }
    mergeRanges(sortedRanges: &ranges, startAt: 0, partial: false)
  }

  /// Merge the ranges in the input array if possible.
  ///
  /// - Parameter sortedRanges: Array of ranges, must be sorted by lowerBound in
  ///   ascending order.
  /// - Parameter startAt: Specifies where to start merging.
  /// - Parameter partial: If `true`, the merging ends when it sees a valid range,
  ///   which does not need to be merged. If `false`, it seeks till the end of the
  ///   array.
  private class func mergeRanges(sortedRanges ranges: inout [CountableRange<Bound>],
                                 startAt: Int,
                                 partial: Bool) {
    guard !ranges.isEmpty else { return }

    var i = startAt
    while i < ranges.count - 1 {
      if ranges[i].upperBound < ranges[i+1].lowerBound {
        if partial {
          return
        }
        i += 1
        continue
      } else {
        ranges[i] = ranges[i].lowerBound ..< max(ranges[i].upperBound, ranges[i+1].upperBound)
        ranges.remove(at: i+1)
      }
    }
  }
}
