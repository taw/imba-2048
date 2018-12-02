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

  def compact_slice(slice)
    let slots = slice.map(do |i| @slots[i])
    let tiles = slots.map(do |slot| slot:tile).filter(do |x| x)
    return if tiles:length == 0

    for i in [0..3]
      if slots[i]:tile == tiles[i]
        continue
      @moved = true
      slots[i]:tile = tiles[i]
      if tiles[i]
        tiles[i]:x = slots[i]:x
        tiles[i]:y = slots[i]:y

    null

  def move_slice(slice)
    compact_slice(slice)
    # merge

  def move(*slices)
    @moved = false
    for slice in slices
      move_slice(slice)

    let after_move = do
      add_tile
      @freeze = false
      Imba.commit

    if @moved
      @freeze = true
      setTimeout((do after_move()), 200)

  def tile_at(x, y)
    @slots[y * 4 + x]:tile

  def add_tile
    if @tiles:length == 16
      console.log "BOARD FULL!"
      return # Game lost probably
    while true
      let value = Math.random() > 0.1 ? 2 : 4
      let x = random_int(0, 3)
      let y = random_int(0, 3)
      if tile_at(x, y)
        continue
      let tile = {x: x, y: y, value: value}
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
            <.tile .{"value-{tile:value}"} css:top=(20 + 120 * tile:y) css:left=(20 + 120 * tile:x)>
              tile:value

Imba.mount <App>
