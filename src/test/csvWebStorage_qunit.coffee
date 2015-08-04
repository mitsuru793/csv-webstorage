webStorage = "localStorage"
storage = localStorage
storage.clear()

tablePrefix = "myTable"
rowsNum = 23
beforeRowsNum = rowsNum
columnsNum = 3
beforeColumnsNum = columnsNum
csvWebStorage = undefined

#init
QUnit.testStart ->
  storage.clear()
  csvWebStorage = new CsvWebStorage tablePrefix, rowsNum, columnsNum
  beforeRowsNum = rowsNum
  beforeColumnsNum = columnsNum

QUnit.testDone ->
  rowsNum = beforeRowsNum
  columnsNum = beforeColumnsNum

#test "constructor", ->

module "getter"
test "getRowKey", ->
  rowIndex = 1
  expected = "#{tablePrefix}_row_#{rowIndex}"

  actual = csvWebStorage.getRowKey(rowIndex)
  equal actual, expected, "Storageに保存してある指定した行のkeyを取得。"

test "getRowKeys", ->
  expected = []
  for i in [0...rowsNum]
    expected.push csvWebStorage.getRowKey(i)

  actual = csvWebStorage.getRowKeys()
  deepEqual actual, expected, "Storageに保存してある行のkeyを全て取得。"

test "getRow", ->
  rowIndex = 0
  rowKey = csvWebStorage.getRowKey rowIndex
  rowValueArray = []
  for i in [0...columnsNum]
    rowValueArray.push String(Math.random() * 5)
  expected = rowValueArray

  storage.setItem rowKey, rowValueArray
  actual = csvWebStorage.getRow(rowIndex)
  deepEqual actual, expected, "Storageに保存してある指定した行の値を取得。"

  expected = null
  actual = csvWebStorage.getRow(rowsNum + 100)
  deepEqual actual, expected, "Storageに存在しない行の値を取得しようとした時はnullが返る。"

test "getColumn", ->
  columnIndex = 0
  columnKey = csvWebStorage.getRowKey columnIndex
  columnValueArray = []
  for i in [0...rowsNum]
    columnValueArray.push String(Math.random() * 5)
  expected = columnValueArray

  csvWebStorage.saveColumn columnValueArray, columnValueArray
  actual = csvWebStorage.getColumn(columnIndex)
  deepEqual actual, expected, "Storageに保存してある指定した列の値を取得。"

  expected = null
  actual = csvWebStorage.getColumn(columnsNum + 100)
  deepEqual actual, expected, "Storageに存在しない列の値を取得しようとした時はnullが返る。"

test "getCell", ->
  rowIndex = 0
  columnsIndex = 0
  rowValueArray = []
  for i in [0...columnsNum]
    rowValueArray.push ''
  rowValueArray[0] = 'A'
  csvWebStorage.saveRow rowIndex, rowValueArray
  
  expected = 'A'
  actual = csvWebStorage.getCell rowIndex, columnsIndex
  equal actual, expected, "Storageに保存してあるセルの値を取得。"

  expected = null
  actual = csvWebStorage.getCell (rowIndex + 100), columnsIndex
  equal actual, expected, "Storageに存在しない行のセルの値を取得しようとした時はnullが返る。"

  expected = null
  actual = csvWebStorage.getCell rowIndex, (columnsIndex + 100)
  equal actual, expected, "Storageに存在しない列のセルの値を取得しようとした時はnullが返る。"

test "getCsv", ->
  csv = ""
  rowCsv = ""
  for i in [0...columnsNum - 1]
    rowCsv += ","
  for i in [0...rowsNum]
    csv += rowCsv + "\n"

  expected = csv
  actual = csvWebStorage.getCsv()
  equal actual, expected, "storageに保存したデータをcsvに変換して文字列として返す"

module "utility"
test "createArrayBySameValue", ->
  expected = ['@','@','@','@']
  actual = csvWebStorage.createArrayBySameValue '@', 4
  deepEqual actual, expected, "指定した文字の要素を指定した数だけ持つ配列を返す。"

  expected = ['']
  actual = csvWebStorage.createArrayBySameValue '', 1
  deepEqual actual, expected, "空文字の要素を1つ持つ配列を返す。"
  
test "createEmptyRow", ->
  expected = ['']
  actual = csvWebStorage.createEmptyRow 1
  deepEqual actual, expected, "列数を1にした時に、空文字の要素を1つ持つ配列を返す。"

  expected = ['', '', '', '', '']
  actual = csvWebStorage.createEmptyRow 5
  deepEqual actual, expected, "列数を4にした時に、空文字の要素を4つ持つ配列を返す。"

  expected = []
  for i in [0...columnsNum]
    expected.push ''
  actual = csvWebStorage.createEmptyRow()
  deepEqual actual, expected, "列数を指定しない時に、現在のテーブルの列数分の空文字の要素を持つ配列を返す。"

test "createEmptyColumn", ->
  expected = ['']
  actual = csvWebStorage.createEmptyColumn 1
  deepEqual actual, expected, "行数を1にした時に、空文字の要素を1つ持つ配列を返す。"

  expected = ['', '', '', '', '']
  actual = csvWebStorage.createEmptyColumn 5
  deepEqual actual, expected, "行数を4にした時に、空文字の要素を4つ持つ配列を返す。"

  expected = []
  for i in [0...rowsNum]
    expected.push ''
  actual = csvWebStorage.createEmptyColumn()
  deepEqual actual, expected, "行数を指定しない時に、現在のテーブルの行数分の空文字の要素を持つ配列を返す。"

module "validate"
test "isEqualColumnsNum", ->
  actual = csvWebStorage.isEqualColumnsNum columnsNum
  ok actual, "指定した数値が、現在のテーブルの列数と等しい場合は真。"

  actual = csvWebStorage.isEqualColumnsNum columnsNum + 1
  notOk actual, "指定した数値が、現在のテーブルの列数と等しくない場合は偽。"

  rowValueArray = []
  for i in [0...columnsNum]
    rowValueArray.push ''
  actual = csvWebStorage.isEqualColumnsNum rowValueArray
  ok actual, "渡した配列の要素数が、テーブルの列数と等しい場合は真。"

  rowValueArray.push ''
  actual = csvWebStorage.isEqualColumnsNum rowValueArray
  notOk actual, "渡した配列の要素数が、テーブルの列数と等しくない場合は偽。"

test "isEqualRowsNum", ->
  actual = csvWebStorage.isEqualRowsNum rowsNum
  ok actual, "指定した数値が、現在のテーブルの行数と等しい場合は真。"

  actual = csvWebStorage.isEqualRowsNum rowsNum + 1
  notOk actual, "指定した数値が、現在のテーブルの行数と等しくない場合は偽。"

  rowValues = []
  for i in [0...rowsNum]
    rowValues.push ''
  actual = csvWebStorage.isEqualRowsNum rowValues
  ok actual, "渡した配列の要素数が、テーブルの行数と等しい場合は真。"

  rowValues.push ''
  actual = csvWebStorage.isEqualRowsNum rowValues
  notOk actual, "渡した配列の要素数が、テーブルの行数と等しくない場合は偽。"

module "row"
test "saveRow", ->
  rowIndex = rowsNum + 11
  rowValueArray = []
  for i in [0...columnsNum]
    rowValueArray.push '@'
  csvWebStorage.saveRow rowIndex, rowValueArray
  rowsNum++

  expected = rowValueArray
  actual = csvWebStorage.getRow rowIndex
  deepEqual actual, expected, "指定した行数に配列を保存。"

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "行を追加後に、インスタンスプロパティのrowsNum（行数）がインクリメントされている。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "行を追加後に、インスタンスプロパティのendRowIndex（最終行のインデックス）がインクリメントされている。"

  csvWebStorage.saveRow rowIndex, rowValueArray

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "既存の行を上書き時には、インスタンスプロパティのrowsNum（行数）がインクリメントされていない。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "既存の行を上書き時には、インスタンスプロパティのendRowIndex（最終行のインデックス）がインクリメントされていない。"

  rowValueArray.pop()
  csvWebStorage.saveRow rowIndex + 100, rowValueArray

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "挿入する配列の長さが列数に等しくない時には、インスタンスプロパティのrowsNum（行数）がインクリメントされていない。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "挿入する配列の長さが列数に等しくない時には、インスタンスプロパティのendRowIndex（最終行のインデックス）がインクリメントされていない。"

  csvWebStorage.saveRow rowIndex + 100, rowValueArray, false
  rowsNum++

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "validateをfalseにした場合は、挿入する配列の長さが等しくなくとも、インスタンスプロパティのrowsNum（行数）がインクリメントされる。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "validateをfalseにした場合は、挿入する配列の長さが列数に等しくなくとも、インスタンスプロパティのendRowIndex（最終行のインデックス）がインクリメントされる。"
  
test "removeRow", ->
  rowIndex = 0
  rowKey = csvWebStorage.getRowKey rowIndex
  csvWebStorage.removeRow rowIndex
  rowsNum--

  expected = null
  actual = localStorage.getItem rowIndex
  equal actual, expected, "指定した行数を削除し、取り出そうとするとnullが返ってくる。"

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "削除後に、インスタンスプロパティのrowsNum（行数）がデクリメントされている。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "削除後に、インスタンスプロパティのendRowIndex（最終行のインデックス）がデクリメントされている。"

  csvWebStorage.removeRow rowIndex + 50

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "存在しない行を削除しようとした時は、インスタンスプロパティのrowsNum（行数）がデクリメントされない。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "存在しない行を削除しようとした時は、インスタンスプロパティのendRowIndex（最終行のインデックス）がデクリメントされない。"

test "pushRow", ->
  rowValueArray = []
  for i in [0...columnsNum]
    rowValueArray.push '@'
  csvWebStorage.pushRow rowValueArray
  rowsNum++

  expected = rowValueArray
  actual = csvWebStorage.getRow rowsNum - 1
  deepEqual actual, expected, "指定した行数に配列を保存。"

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "行をプッシュ後に、インスタンスプロパティのrowsNum（行数）がインクリメントされている。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "行をプッシュ後に、インスタンスプロパティのendRowIndex（最終行のインデックス）がインクリメントされている。"

  rowValueArray.pop()
  csvWebStorage.pushRow rowValueArray

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "プッシュする配列の長さが列数に等しくない時には、インスタンスプロパティのrowsNum（行数）がインクリメントされていない。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "プッシュする配列の長さが列数に等しくない時には、インスタンスプロパティのendRowIndex（最終行のインデックス）がインクリメントされていない。"

test "popRow", ->
  csvWebStorage.popRow()
  rowsNum--

  # rowsNumをindexとして指定しているため、popする前の末尾になる
  expected = null
  actual = csvWebStorage.getRow rowsNum
  equal actual, expected, "ポップ前の末尾の行の値を取得しようした時にnullが返る"

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "ポップ後に、インスタンスプロパティのrowsNum（行数）がデクリメントされている。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "ポップ後に、インスタンスプロパティのendRowIndex（最終行のインデックス）がデクリメントされている。"

test "addRow", ->
  addNum = 3
  rowValueArray = []
  for i in [0...columnsNum]
    rowValueArray.push '@'
  csvWebStorage.addRow addNum, rowValueArray
  rowsNum += addNum

  expected = rowValueArray
  isSuccess = true
  # 末尾からチェック
  for i in [0...addNum]
    actual = csvWebStorage.getRow (rowsNum - 1) - i
    if actual.toString() isnt expected.toString()
      isSuccess = false
      break
  ok isSuccess, "指定した配列が、指定した数だけ最終行の次から追加される"

  rowValueArray = []
  for i in [0...columnsNum]
    rowValueArray.push ''
  csvWebStorage.addRow addNum
  rowsNum += addNum

  expected = rowValueArray
  isSuccess = true
  # 末尾からチェック
  for i in [0...addNum]
    actual = csvWebStorage.getRow (rowsNum - 1) - i
    if actual.toString() isnt expected.toString()
      isSuccess = false
      break
  ok isSuccess, "追加する配列を指定しない時は、空行が追加される。"

  rowValueArray.pop()
  csvWebStorage.addRow addNum, rowValueArray

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "追加する配列の長さが列数に等しくない時には、インスタンスプロパティのrowsNum（行数）がインクリメントされていない。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "追加する配列の長さが列数に等しくない時には、インスタンスプロパティのendRowIndex（最終行のインデックス）がインクリメントされていない。"
  
test "subRow", ->
  subNum = 2
  csvWebStorage.subRow subNum
  rowsNum -= subNum

  isSuccess = true
  for i in [0...subNum]
    endRowIndex = ((rowsNum + subNum) - 1) - i
    if csvWebStorage.getRow endRowIndex isnt null
      isSuccess = false
      break
  ok isSuccess, "最終行から指定した行数を削除し、取り出そうとすると全てnullが返ってくる。"

  expected = rowsNum
  actual = csvWebStorage.rowsNum
  equal actual, expected, "削除後に、インスタンスプロパティのrowsNum（行数）がデクリメントされている。"

  expected = rowsNum - 1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "削除後に、インスタンスプロパティのendRowIndex（最終行のインデックス）がデクリメントされている。"

  csvWebStorage.subRow rowsNum + 10
  expected = 0
  actual = csvWebStorage.rowsNum
  equal actual, expected, "存在している行数以上を削除しようとした時は、インスタンスプロパティのrowsNum（行数）が0になる"

  expected = -1
  actual = csvWebStorage.endRowIndex
  equal actual, expected, "存在している行数以上を削除しようとした時は、インスタンスプロパティのendRowIndex（最終行のインデックス）が-1になる。"

module "column"
test "saveColumn", ->
  columnIndex = columnsNum
  columnValueArray = []
  for i in [0...rowsNum]
    columnValueArray.push '@'
  csvWebStorage.saveColumn columnIndex, columnValueArray
  columnsNum++

  expected = columnValueArray
  actual = csvWebStorage.getColumn columnIndex
  deepEqual actual, expected, "指定した列数に配列を保存。"

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "列を追加後に、インスタンスプロパティのcolumnsNum（列数）がインクリメントされている。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "列を追加後に、インスタンスプロパティのendColumnIndex（最終列のインデックス）がインクリメントされている。"

  columnValueArray = []
  for i in rowsNum
    columnValueArray.push ''
  csvWebStorage.saveColumn columnIndex, columnValueArray

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "既存の列を上書き時には、インスタンスプロパティのcolumnsNum（列数）がインクリメントされていない。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "既存の列を上書き時には、インスタンスプロパティのendColumnIndex（最終列のインデックス）がインクリメントされていない。"

  columnValueArray.pop()
  csvWebStorage.saveColumn columnIndex + 20, columnValueArray

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "挿入する配列の長さが行数に等しくない時には、インスタンスプロパティのcolumnsNum（列数）がインクリメントされていない。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "挿入する配列の長さが行数に等しくない時には、インスタンスプロパティのendColumnIndex（最終列のインデックス）がインクリメントされていない。"

  csvWebStorage.removeColumn columnIndex + 50

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "存在しない列を削除しようとした時は、インスタンスプロパティのcolumnsNum（列数）がデクリメントされない。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "存在しない列を削除しようとした時は、インスタンスプロパティのendColumnIndex（最終列のインデックス）がデクリメントされない。"

  csvWebStorage.saveColumn columnIndex + 100, columnValueArray, false
  columnsNum++

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "validateをfalseにした場合は、挿入する配列の長さが等しくなくとも、インスタンスプロパティのcolumnsNum（列数）がインクリメントされる。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "validateをfalseにした場合は、挿入する配列の長さが行数に等しくなくとも、インスタンスプロパティのendColumnIndex（最終列のインデックス）がインクリメントされる。"

test "removeColumn", ->
  columnIndex = columnsNum - 1
  csvWebStorage.removeColumn columnIndex
  columnsNum--

  expected = null
  actual = csvWebStorage.getColumn columnIndex
  equal actual, expected, "最後の列を削除し、取り出そうとするとnullが返ってくる。"

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "削除後に、インスタンスプロパティのcolumnsNum（列数）がデクリメントされている。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "削除後に、インスタンスプロパティのendColumnIndex（最終列のインデックス）がデクリメントされている。"

test "pushColumn", ->
  columnValueArray = []
  for i in [0...rowsNum]
    columnValueArray.push '@'
  csvWebStorage.pushColumn columnValueArray
  columnsNum++

  expected = columnValueArray
  actual = csvWebStorage.getColumn columnsNum - 1
  deepEqual actual, expected, "指定した列数に配列を保存。"

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "列をプッシュ後に、インスタンスプロパティのcolumnsNum（列数）がインクリメントされている。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "列をプッシュ後に、インスタンスプロパティのendColumnIndex（最終列のインデックス）がインクリメントされている。"

  columnValueArray.pop()
  csvWebStorage.pushColumn columnValueArray

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "プッシュする配列の長さが行数に等しくない時には、インスタンスプロパティのcolumnsNum（列数）がインクリメントされていない。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "プッシュする配列の長さが行数に等しくない時には、インスタンスプロパティのendColumnIndex（最終列のインデックス）がインクリメントされていない。"
  
test "popColumn", ->
  csvWebStorage.popColumn()
  columnsNum--

  # columnsNumをindexとして指定しているため、popする前の末尾になる
  expected = null
  actual = csvWebStorage.getColumn columnsNum
  equal actual, expected, "ポップ前の末尾の列の値を取得しようした時にnullが返る"

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "ポップ後に、インスタンスプロパティのcolumnsNum（列数）がデクリメントされている。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "ポップ後に、インスタンスプロパティのendColumnIndex（最終列のインデックス）がデクリメントされている。"

test "addColumn", ->
  addNum = 3
  columnValueArray = []
  for i in [0...rowsNum]
    columnValueArray.push '@'
  csvWebStorage.addColumn addNum, columnValueArray
  columnsNum += addNum

  expected = columnValueArray
  isSuccess = true
  # 末尾からチェック
  for i in [0...addNum]
    actual = csvWebStorage.getColumn (columnsNum - 1) - i
    if actual.toString() isnt expected.toString()
      isSuccess = false
      break
  ok isSuccess, "指定した配列が、指定した数だけ最終列の次から追加される"

  columnValueArray = []
  for i in [0...rowsNum]
    columnValueArray.push ''
  csvWebStorage.addColumn addNum
  columnsNum += addNum

  expected = columnValueArray
  isSuccess = true
  # 末尾からチェック
  for i in [0...addNum]
    actual = csvWebStorage.getColumn (columnsNum - 1) - i
    if actual.toString() isnt expected.toString()
      isSuccess = false
      break
  ok isSuccess, "追加する配列を指定しない時は、空列が追加される。"

  columnValueArray.pop()
  csvWebStorage.addColumn addNum, columnValueArray

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "追加する配列の長さが行数に等しくない時には、インスタンスプロパティのcolumnsNum（列数）がインクリメントされていない。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "追加する配列の長さが行数に等しくない時には、インスタンスプロパティのendColumnIndex（最終列のインデックス）がインクリメントされていない。"

test "subColumn", ->
  subNum = 2
  csvWebStorage.subColumn subNum
  beforeColumnsNum = columnsNum
  columnsNum -= subNum

  isSuccess = true
  # 末尾からチェック
  for i in [0...subNum]
    if csvWebStorage.getColumn(beforeColumnsNum - 1 - i) isnt null
      isSuccess = false
      break
  ok isSuccess, "最終列から指定した列数を削除し、取り出そうとすると全てnullが返ってくる。"

  expected = columnsNum
  actual = csvWebStorage.columnsNum
  equal actual, expected, "削除後に、インスタンスプロパティのcolumnsNum（列数）がデクリメントされている。"

  expected = columnsNum - 1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "削除後に、インスタンスプロパティのendColumnIndex（最終列のインデックス）がデクリメントされている。"

  csvWebStorage.subColumn columnsNum + 10
  expected = 0
  actual = csvWebStorage.columnsNum
  equal actual, expected, "存在している列数以上を削除しようとした時は、インスタンスプロパティのcolumnsNum（列数）が0になる"

  expected = -1
  actual = csvWebStorage.endColumnIndex
  equal actual, expected, "存在している列数以上を削除しようとした時は、インスタンスプロパティのendColumnIndex（最終列のインデックス）が-1になる。"

module "cell"
test "saveCell", ->
  rowIndex = 5
  columnIndex = 2
  cellValue = "testValue"
  csvWebStorage.saveCell rowIndex, columnIndex, cellValue

  expected = cellValue
  actual = csvWebStorage.getRow(rowIndex)[columnIndex]
  equal actual, expected, "特定のcellに値を保存できる"
