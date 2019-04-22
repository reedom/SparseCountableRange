// https://github.com/Quick/Quick

import Quick
import Nimble
import SparseRanges

class SparseCountableRangeSpec: QuickSpec {
  override func spec() {
    describe("initial state") {
      let r = SparseCountableRange<Int>()
      it("should be empty") {
        expect(r.isEmpty) == true
        expect(r.countOfRanges) == 0
        expect(r.countOfElements) == 0
      }
    }
    
    describe("initial range") {
      var source = [10..<20, 30..<40]
      let r = SparseCountableRange<Int>(initial: source)
      it("should have a range") {
        expect(r.isEmpty).to(beFalse())
        expect(r.countOfRanges) == 2
        expect(r.countOfElements) == 20
      }
      
      it("should be independant from the source") {
        expect(source) == [10..<20, 30..<40]
        source.removeAll(keepingCapacity: false)
        expect(source) == []
        expect(r.ranges) == [10..<20, 30..<40]
      }
    }
    
    describe("initial range contains empty ranges") {
      let source = [0..<0, 0..<0]
      let r = SparseCountableRange<Int>(initial: source)
      it("should be empty") {
        expect(r.isEmpty) == true
        expect(r.countOfElements) == 0
      }
    }
    
    describe("initial range normalization") {
      let source = [20..<30, 10..<20, 3..<5, 2..<4, 2..<4, 2..<6, 31..<32]
      let r = SparseCountableRange<Int>(initial: source)
      it("should be normalized") {
        expect(r.isEmpty) == false
        expect(r.ranges) == [2..<6, 10..<30, 31..<32]
      }
    }
    
    describe("gaps") {
      it("will return input if it has no ranges") {
        let r = SparseCountableRange<Int>()
        expect(r.gaps(0..<2)) == [0..<2]
      }
      
      it("will return gaps") {
        let r = SparseCountableRange<Int>(initial: [10..<20, 30..<40, 50..<60])
        expect(r.gaps(1..<9)) == [1..<9]
        expect(r.gaps(1..<10)) == [1..<10]
        expect(r.gaps(1..<11)) == [1..<10]
        expect(r.gaps(1..<20)) == [1..<10]
        expect(r.gaps(10..<20)).to(beNil())
        expect(r.gaps(1..<61)) == [1..<10, 20..<30, 40..<50, 60..<61]
        expect(r.gaps(25..<61)) == [25..<30, 40..<50, 60..<61]
        expect(r.gaps(60..<70)) == [60..<70]
        expect(r.gaps(61..<70)) == [61..<70]
      }

      it("will return one gap") {
        let r = SparseCountableRange<Int>(initial: [0..<3])
        expect(r.gaps(0..<6)) == [3..<6]
      }
    }
    
    describe("add") {
      it("will return false for empty range") {
        var r = SparseCountableRange<Int>()
        expect(r.add(0..<0)).to(beFalse())
      }
      
      it("will add") {
        var r = SparseCountableRange<Int>()
        // initial
        expect(r.add(30..<40)).to(beTrue())
        expect(r.ranges) == [30..<40]
        // before
        expect(r.add(10..<20)).to(beTrue())
        expect(r.ranges) == [10..<20, 30..<40]
        // after
        expect(r.add(50..<60)).to(beTrue())
        expect(r.ranges) == [10..<20, 30..<40, 50..<60]
        // middle
        expect(r.add(25..<26)).to(beTrue())
        expect(r.ranges) == [10..<20, 25..<26, 30..<40, 50..<60]
        // middle
        expect(r.add(26..<27)).to(beTrue())
        expect(r.ranges) == [10..<20, 25..<27, 30..<40, 50..<60]
        expect(r.add(24..<34)).to(beTrue())
        expect(r.ranges) == [10..<20, 24..<40, 50..<60]
        // cover entire range
        expect(r.add(10..<60)).to(beTrue())
        expect(r.ranges) == [10..<60]
        expect(r.add(1..<70)).to(beTrue())
        expect(r.ranges) == [1..<70]
      }
      
      it("will return false for already contained ranges") {
        var r = SparseCountableRange<Int>(initial: [1..<10])
        expect(r.add(1..<10)).to(beFalse())
        expect(r.add(1..<2)).to(beFalse())
        expect(r.add(9..<10)).to(beFalse())
      }
    }

    describe("removeAll") {
      it("will empty the collection") {
        var r = SparseCountableRange<Int>(initial: [1..<10])
        expect(r.isEmpty).to(beFalse())
        r.removeAll()
        expect(r.isEmpty).to(beTrue())
      }
    }
  }
}
