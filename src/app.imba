let def random_int(min, max)
  min + Math.floor(Math.random() * (max - min + 1))

tag App
  def setup
    @slots = []
    for y in [0..3]
      for x in [0..3]
        @slots.push({x: x, y: y, tile: null})
    @tiles = []
    add_tile
    add_tile

  # For css testing
  def setup_all_colors
    @tiles.push({x: 0, y: 0, value: 2, key: Math.random()})
    @tiles.push({x: 1, y: 0, value: 4, key: Math.random()})
    @tiles.push({x: 2, y: 0, value: 8, key: Math.random()})
    @tiles.push({x: 3, y: 0, value: 16, key: Math.random()})
    @tiles.push({x: 0, y: 1, value: 32, key: Math.random()})
    @tiles.push({x: 1, y: 1, value: 64, key: Math.random()})
    @tiles.push({x: 2, y: 1, value: 128, key: Math.random()})
    @tiles.push({x: 3, y: 1, value: 256, key: Math.random()})
    @tiles.push({x: 0, y: 2, value: 512, key: Math.random()})
    @tiles.push({x: 1, y: 2, value: 1024, key: Math.random()})
    @tiles.push({x: 2, y: 2, value: 2048, key: Math.random()})
    @tiles.push({x: 3, y: 2, value: 4096, key: Math.random()})

  def move_to_slot(slot, tile)
    slot:tile = tile
    if tile
      tile:x = slot:x
      tile:y = slot:y

  def compact_slice(slice)
    let slots = slice.map(do |i| @slots[i])
    let tiles = slots.map(do |slot| slot:tile).filter(do |x| x)
    for i in [0..3]
      if slots[i]:tile == tiles[i]
        continue
      @moved = true
      move_to_slot slots[i], tiles[i]
    null

  def merge_same(slice)
    let slots = slice.map(do |i| @slots[i])
    return unless slots:length >= 2
    return unless slots[1]:tile

    let t0 = slots[0]:tile
    let t1 = slots[1]:tile

    if t0:value == t1:value
      t0:value *= 2
      @moved = true
      t1:deleted = true
      slots[1]:tile = null
      move_to_slot slots[0], t1
      move_to_slot slots[0], t0
      # Quick compact so we can try again
      if slots[2]
        move_to_slot slots[1], slots[2]:tile
        slots[2]:tile = null
      if slots[3]
        move_to_slot slots[2], slots[3]:tile
        slots[3]:tile = null

    merge_same slice.slice(1)

  def move_slice(slice)
    compact_slice(slice)
    merge_same(slice)

  def move(*slices)
    @moved = false
    @deleteme = []
    for slice in slices
      move_slice(slice)

    let after_move = do
      add_tile
      @freeze = false
      @tiles = @tiles.filter(do |t| !t:deleted)
      Imba.commit

    if @moved
      @freeze = true
      setTimeout((do after_move()), 200)

  def tile_at(x, y)
    @slots[y * 4 + x]:tile

  def board_full
    @tiles.filter(do |t| !t:deleted):length == 16

  def add_tile
    if board_full
      console.log "BOARD FULL!"
      return # Game lost probably
    let value = Math.random() > 0.1 ? 2 : 4
    while true
      let x = random_int(0, 3)
      let y = random_int(0, 3)
      if tile_at(x, y)
        continue
      let tile = {x: x, y: y, value: value, key: Math.random()}
      @tiles.push(tile)
      @slots[y * 4 + x]:tile = tile
      break

  def mount
    document.add-event-listener("keydown") do |event|
      handle_key(event)
      Imba.commit

  def handle_key(event)
    return if @freeze
    if event:key == "ArrowLeft"
      move([0,1,2,3], [4,5,6,7], [8,9,10,11], [12,13,14,15])
    if event:key == "ArrowRight"
      move([3,2,1,0], [7,6,5,4], [11,10,9,8], [15,14,13,12])
    if event:key == "ArrowDown"
      move([12,8,4,0], [13,9,5,1], [14,10,6,2], [15,11,7,3])
    if event:key == "ArrowUp"
      move([0,4,8,12], [1,5,9,13], [2,6,10,14], [3,7,11,15])

  def render
    <self>
      <header>
        "2048 Game"
      <#game>
        <.grid>
          for slot in @slots
            <.slot css:top=(20 + 120 * slot:y) css:left=(20 + 120 * slot:x)>
          for tile in @tiles
            unless tile:deleted
              <.tile@{tile:key} .{"value-{tile:value}"} css:top=(20 + 120 * tile:y) css:left=(20 + 120 * tile:x)>
                tile:value

Imba.mount <App>
