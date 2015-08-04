class @CsvWebStorage
  constructor: (@tablePrefix, @rowsNum, @columnsNum, @storage=localStorage) ->
    @csvDelimiter = ','
    @rowPrefix = "#{@tablePrefix}_row"
    @rowRegExp = new RegExp(@rowPrefix + '_(\\d+)')

    @endRowIndex = @rowsNum - 1
    @endColumnIndex = @columnsNum - 1

    @initTable @rowsNum, @columnsNum

  ###
  init
  ###
  initTable: (rowsNum, columnsNum) ->
    @storage.clear()
    rowValue = @createEmptyRow columnsNum
    for i in [0...rowsNum]
      @storage.setItem @getRowKey(i), rowValue
  ###
  getter
  ###
  getRowKey: (rowIndex) ->
    return @rowPrefix + '_' + rowIndex

  getRowKeys: ->
    storageKeys = Object.keys @storage
    storageRowKeys = storageKeys
      .filter (value, index) =>
        return @rowRegExp.test value
      # 0 未満の場合、a を b より小さい添字にソートします。
      # 0 より大きい場合、b を a より小さい添字にソートします。
      # rowIndexの昇順
      .sort (a, b) =>
        return if Number(@rowRegExp.exec(a)[1]) < Number(@rowRegExp.exec(b)[1]) then -1 else 1
    return storageRowKeys

  getRow: (rowIndex) =>
    rowKey = @getRowKey rowIndex
    rowValueString = @storage.getItem rowKey
    if rowValueString?
      return rowValueString.split(@csvDelimiter)
    else
      return null

  getColumn: (columnIndex) ->
    columnValueArray = []
    isExist = false
    for rowIndex in [0...@rowsNum]
      rowVauleArray = @getRow rowIndex
      if columnValueArray[columnIndex]?
        isExist = true
      columnValueArray.push rowVauleArray[columnIndex]
    if isExist
      return columnValueArray
    else
      return null

  getCell: (rowIndex, columnIndex) ->
    rowValueArray = @getRow rowIndex
    if rowValueArray is null
      return null
    cellValue = rowValueArray[columnIndex]
    return cellValue

  getCsv: ->
    csv = ""
    for i in [0...@rowsNum]
      csv += @getRow(i).join(@csvDelimiter) + "\n"
    return csv

  ###
  utility
  ###
  createArrayBySameValue: (sameValue, elementsNum) ->
    values = []
    for i in [0...elementsNum]
      values.push sameValue
    return values

  createEmptyRow: (columnsNum=@columnsNum) ->
    return @createArrayBySameValue '', columnsNum
  
  createEmptyColumn: (rowsNum=@rowsNum) ->
    return @createArrayBySameValue '', rowsNum

  ###
  validate
  ###
  isEqualColumnsNum: (num) ->
    if num instanceof Array
      num = num.length
    return num is @columnsNum

  isEqualRowsNum: (num) ->
    if num instanceof Array
      num = num.length
    return num is @rowsNum

  ###
  update data
  ###
  
  # row
   
  # @param [Number] rowIndex
  # @param [Array] rowValueArray 要素数は列数に一致すること
  saveRow: (rowIndex, rowValueArray, validate=true) ->
    if validate and not @isEqualColumnsNum rowValueArray
      return false
    if @getRow(rowIndex) is null
      @rowsNum++
      @endRowIndex++

    rowKey = @getRowKey rowIndex
    @storage.setItem rowKey, rowValueArray.join(@csvDelimiter)
    return

  removeRow: (rowIndex) ->
    if @getRow(rowIndex) is null
      return false
    else
      @rowsNum--
      @endRowIndex--

    rowKey = @getRowKey rowIndex
    @storage.removeItem rowKey
    return

  pushRow: (rowValueArray) ->
    if not @isEqualColumnsNum rowValueArray
      return false
    @saveRow @rowsNum, rowValueArray
    return

  popRow: ->
    rowValueArray = @getRow @endRowIndex
    @removeRow @endRowIndex
    return rowValueArray
    
  addRow: (addNum, rowValueArray=null) ->
    if not rowValueArray?
      rowValueArray = @createEmptyRow()
    for i in [1..addNum]
      @saveRow @endRowIndex + 1, rowValueArray

    return

  subRow: (subNum) ->
    for i in [0...subNum]
      @removeRow @endRowIndex
    return

  # column

  # 全行のうち1列を更新
  # 
  # @param [Number] columnIndex
  # @param [Array] columnValueArray 要素数は行数に一致すること
  saveColumn: (columnIndex, columnValueArray, validate=true) ->
    if validate and not @isEqualRowsNum columnValueArray
      return false
    for rowIndex in [0...@rowsNum]
      rowValueArray = @getRow(rowIndex)
      rowValueArray.splice columnIndex, 1, columnValueArray[rowIndex]
      rowKey = @getRowKey rowIndex
      @storage.setItem rowKey, rowValueArray.join(@csvDelimiter)
    @columnsNum++
    @endColumnIndex++
    return

  removeColumn: (columnIndex) ->
    if @getColumn(columnIndex) is null
      return false
    else
      @columnsNum--
      @endColumnIndex--
    for rowIndex in [0...@rowsNum]
      rowValueArray = @getRow(rowIndex)
      rowValueArray.splice columnIndex, 1
      @saveRow rowIndex, rowValueArray, false
    return
  
  pushColumn: (columnValueArray) ->
    if not @isEqualRowsNum columnValueArray
      return false
    @saveColumn @columnsNum, columnValueArray
    return

  popColumn: ->
    columnValueArray = @getColumn @endColumnIndex
    @removeColumn @endColumnIndex
    return columnValueArray

  addColumn: (addNum, columnValueArray=null) ->
    if not columnValueArray?
      columnValueArray = @createEmptyColumn()
    for i in [1..addNum]
      @saveColumn @endColumnIndex + 1, columnValueArray
    return

  subColumn: (subNum)->
    for i in [0...subNum]
      @removeColumn @endColumnIndex - i

  # cell
  
  saveCell: (rowIndex, columnIndex, value) ->
    rowValueArray = @getRow rowIndex
    rowValueArray[columnIndex] = value
    @saveRow rowIndex, rowValueArray
