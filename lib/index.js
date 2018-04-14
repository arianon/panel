const os = require("os")
const { cpu, memory, clock, calendar, dolartoday } = require("./blocks")

const json = v => JSON.stringify(v, null, 2)

const log = v => console.log(json(v) + ",")

function dispatch() {
  const state = {}
  const blocks = [cpu, memory, dolartoday, calendar, clock]

  async function callback(block) {
    state[block.id] = await block()
    log(blocks.map(block => state[block.id]).filter(Boolean))
  }

  blocks.forEach(async block => {
    await callback(block)
    setInterval(() => callback(block), block.interval)
  })
}

module.exports = {
  json,
  log,
  dispatch
}
