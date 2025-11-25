package feathers.flex.data;

import openfl.errors.IllegalOperationError;
import openfl.errors.RangeError;
import openfl.events.Event;
import feathers.events.FlatCollectionEvent;
import mx.collections.ArrayList;
import mx.collections.IList;
import utest.Assert;
import utest.Test;

class FlexListCollectionArrayListTests extends Test {
	private static final TEXT_FILTER_ME = "__FILTER_ME__";

	private var _list:IList;
	private var _collection:FlexListCollection;
	private var _a:MockItem;
	private var _b:MockItem;
	private var _c:MockItem;
	private var _d:MockItem;

	public function new() {
		super();
	}

	public function setup():Void {
		this._a = new MockItem("A", 0);
		this._b = new MockItem("B", 2);
		this._c = new MockItem("C", 3);
		this._d = new MockItem("D", 1);
		this._list = new ArrayList([this._a, this._b, this._c, this._d]);
		this._collection = new FlexListCollection(this._list);
	}

	public function teardown():Void {
		this._collection = null;
	}

	private function filterFunction(item:MockItem):Bool {
		if (item == this._a || item == this._c || item.text == TEXT_FILTER_ME) {
			return false;
		}
		return true;
	}

	private function sortCompareFunction(a:MockItem, b:MockItem):Int {
		var valueA = a.value;
		var valueB = b.value;
		if (valueA < valueB) {
			return -1;
		}
		if (valueA > valueB) {
			return 1;
		}
		return 0;
	}

	public function testIndexOf():Void {
		Assert.equals(0, this._collection.indexOf(this._a), "Collection indexOf() returns wrong index");
		Assert.equals(1, this._collection.indexOf(this._b), "Collection indexOf() returns wrong index");
		Assert.equals(2, this._collection.indexOf(this._c), "Collection indexOf() returns wrong index");
		Assert.equals(3, this._collection.indexOf(this._d), "Collection indexOf() returns wrong index");
		Assert.equals(-1, this._collection.indexOf(new MockItem("Not in collection", -1)), "Collection indexOf() must return -1 for items not in collection");
	}

	public function testContains():Void {
		Assert.isTrue(this._collection.contains(this._a), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._b), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._d), "Collection contains() returns wrong result for item in collection");
		Assert.isTrue(this._collection.contains(this._d), "Collection contains() returns wrong result for item in collection");
		Assert.isFalse(this._collection.contains(new MockItem("Not in collection", -1)),
			"Collection contains() returns wrong result for item not in collection");
	}

	public function testGet():Void {
		Assert.equals(this._a, this._collection.get(0), "Collection get() returns wrong item");
		Assert.equals(this._b, this._collection.get(1), "Collection get() returns wrong item");
		Assert.equals(this._c, this._collection.get(2), "Collection get() returns wrong item");
		Assert.equals(this._d, this._collection.get(3), "Collection get() returns wrong item");
		Assert.raises(function() {
			this._collection.get(100);
		}, RangeError);
		Assert.raises(function() {
			this._collection.get(-1);
		}, RangeError);
	}

	public function testAdd():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var originalLength = this._collection.length;
		var expectedIndex = originalLength;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.add(itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(addItemEvent, "FlatCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.equals(originalLength + 1, this._collection.length, "Collection length must change after adding to collection");
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd), "Adding item to collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Adding item to collection returns incorrect index in event");
	}

	public function testAddAt():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addAt(itemToAdd, expectedIndex);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after adding to collection");
		Assert.isTrue(addItemEvent, "FlatCollectionEvent.ADD_ITEM must be dispatched after adding to collection");
		Assert.equals(originalLength + 1, this._collection.length, "Collection length must change after adding to collection");
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd), "Adding item to collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Adding item to collection returns incorrect index in event");

		Assert.raises(function() {
			this._collection.addAt(itemToAdd, 100);
		}, RangeError);
		Assert.raises(function() {
			this._collection.addAt(itemToAdd, -1);
		}, RangeError);
	}

	public function testSetReplace():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, function(event:FlatCollectionEvent):Void {
			replaceItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.set(expectedIndex, itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after replacing in collection");
		Assert.isFalse(addItemEvent, "FlatCollectionEvent.ADD_ITEM must not be dispatched after replacing in collection");
		Assert.isTrue(replaceItemEvent, "FlatCollectionEvent.REPLACE_ITEM must be dispatched after replacing in collection");
		Assert.equals(originalLength, this._collection.length, "Collection length must not change after replacing in collection");
		Assert.equals(expectedIndex, this._collection.indexOf(itemToAdd), "Replacing item in collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Replacing item in collection returns incorrect index in event");

		Assert.raises(function() {
			this._collection.set(100, itemToAdd);
		}, RangeError);
		Assert.raises(function() {
			this._collection.set(-1, itemToAdd);
		}, RangeError);
	}

	public function testSetAfterEnd():Void {
		var itemToAdd = new MockItem("New Item", 100);
		var originalLength = this._collection.length;
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var addItemEvent = false;
		var replaceItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.ADD_ITEM, function(event:FlatCollectionEvent):Void {
			addItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.addEventListener(FlatCollectionEvent.REPLACE_ITEM, function(event:FlatCollectionEvent):Void {
			replaceItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.set(originalLength, itemToAdd);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after setting item after end of collection");
		Assert.isTrue(addItemEvent, "FlatCollectionEvent.ADD_ITEM must be dispatched after setting item after end of collection");
		Assert.isFalse(replaceItemEvent, "FlatCollectionEvent.REPLACE_ITEM must not be dispatched after setting item after end of collection");
		Assert.equals(originalLength + 1, this._collection.length, "Collection length must change after setting item after end of collection");
		Assert.equals(originalLength, this._collection.indexOf(itemToAdd), "Setting item after end of collection returns incorrect index");
		Assert.equals(originalLength, indexFromEvent, "Setting item after end of collection returns incorrect index in event");
	}

	public function testRemove():Void {
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var itemToRemove = this._collection.get(expectedIndex);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ITEM, function(event:FlatCollectionEvent):Void {
			removeItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.remove(itemToRemove);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(removeItemEvent, "FlatCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.equals(originalLength - 1, this._collection.length, "Collection length must change after removing from collection");
		Assert.equals(-1, this._collection.indexOf(itemToRemove), "Removing item from collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Removing item from collection returns incorrect index in event");
	}

	public function testRemoveAt():Void {
		var originalLength = this._collection.length;
		var expectedIndex = 1;
		var itemToRemove = this._collection.get(expectedIndex);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeItemEvent = false;
		var indexFromEvent = -1;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ITEM, function(event:FlatCollectionEvent):Void {
			removeItemEvent = true;
			indexFromEvent = event.index;
		});
		this._collection.removeAt(expectedIndex);
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing from collection");
		Assert.isTrue(removeItemEvent, "FlatCollectionEvent.REMOVE_ITEM must be dispatched after removing from collection");
		Assert.equals(originalLength - 1, this._collection.length, "Collection length must change after removing from collection");
		Assert.equals(-1, this._collection.indexOf(itemToRemove), "Removing item from collection returns incorrect index");
		Assert.equals(expectedIndex, indexFromEvent, "Removing item from collection returns incorrect index in event");

		Assert.raises(function() {
			this._collection.removeAt(100);
		}, RangeError);
		Assert.raises(function() {
			this._collection.removeAt(-1);
		}, RangeError);
	}

	public function testRemoveAll():Void {
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ALL, function(event:FlatCollectionEvent):Void {
			removeAllEvent = true;
		});
		var resetEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.RESET, function(event:FlatCollectionEvent):Void {
			resetEvent = true;
		});
		this._collection.removeAll();
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after removing all from collection");
		Assert.isTrue(removeAllEvent, "FlatCollectionEvent.REMOVE_ALL must be dispatched after removing all from collection");
		Assert.isFalse(resetEvent, "FlatCollectionEvent.RESET must not be dispatched after removing all from collection");
		Assert.equals(0, this._collection.length, "Collection length must change after removing all from collection");
	}

	public function testRemoveAllWithEmptyCollection():Void {
		this._collection = new FlexListCollection();
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ALL, function(event:FlatCollectionEvent):Void {
			removeAllEvent = true;
		});
		this._collection.removeAll();
		Assert.isFalse(changeEvent, "Event.CHANGE must not be dispatched after removing all from empty collection");
		Assert.isFalse(removeAllEvent, "FlatCollectionEvent.REMOVE_ALL must not be dispatched after removing all from empty collection");
	}

	public function testResetList():Void {
		var newList = new ArrayList([this._c, this._b, this._a]);
		var changeEvent = false;
		this._collection.addEventListener(Event.CHANGE, function(event:Event):Void {
			changeEvent = true;
		});
		var removeAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.REMOVE_ALL, function(event:FlatCollectionEvent):Void {
			removeAllEvent = true;
		});
		var resetEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.RESET, function(event:FlatCollectionEvent):Void {
			resetEvent = true;
		});
		this._collection.list = newList;
		Assert.isTrue(changeEvent, "Event.CHANGE must be dispatched after resetting collection");
		Assert.isTrue(resetEvent, "FlatCollectionEvent.RESET must be dispatched after resetting collection");
		Assert.isFalse(removeAllEvent, "FlatCollectionEvent.REMOVE_ALL must not be dispatched after resetting from collection");
		Assert.equals(newList.length, this._collection.length, "Collection length must change after resetting collection with data of new size");
	}

	public function testResetArrayToNull():Void {
		this._collection.list = null;
		Assert.isOfType(this._collection.list, ArrayList, "Setting collection source to null should replace with an empty value.");
		Assert.equals(0, this._collection.length, "Collection length must change after resetting collection source with empty valee");
	}

	public function testUpdateAt():Void {
		var updateItemEvent = false;
		var updateItemIndex = -1;
		this._collection.addEventListener(FlatCollectionEvent.UPDATE_ITEM, function(event:FlatCollectionEvent):Void {
			updateItemEvent = true;
			updateItemIndex = event.index;
		});
		this._collection.updateAt(1);
		Assert.isTrue(updateItemEvent, "FlatCollectionEvent.UPDATE_ITEM must be dispatched after calling updateAt()");
		Assert.equals(1, updateItemIndex, "FlatCollectionEvent.UPDATE_ITEM must be dispatched with correct index");

		Assert.raises(function():Void {
			this._collection.updateAt(100);
		}, RangeError);
		Assert.raises(function():Void {
			this._collection.updateAt(-1);
		}, RangeError);
	}

	public function testUpdateAll():Void {
		var updateAllEvent = false;
		this._collection.addEventListener(FlatCollectionEvent.UPDATE_ALL, function(event:FlatCollectionEvent):Void {
			updateAllEvent = true;
		});
		this._collection.updateAll();
		Assert.isTrue(updateAllEvent, "FlatCollectionEvent.UPDATE_ALL must be dispatched after calling updateAll()");
	}

	public function testFilterFunction():Void {
		// not supported unless ICollectionView is implemented
		Assert.raises(() -> {
			this._collection.filterFunction = filterFunction;
		}, IllegalOperationError);
	}

	public function testSortCompareFunction():Void {
		// not supported unless ICollectionView is implemented
		Assert.raises(() -> {
			this._collection.sortCompareFunction = sortCompareFunction;
		}, IllegalOperationError);
	}
}

private class MockItem {
	public function new(text:String, value:Float) {
		this.text = text;
		this.value = value;
	}

	public var text:String;
	public var value:Float;
}
