const os = require("os")
const uuid = require("uuid")
const moment = require("moment")
const fetch = require('node-fetch')

const block = ({ interval, icon }, callback) => {
  const f = async () => {
    const text = await callback()

    return {
      full_text: `<span background='white' foreground='black'> ${icon.trim()} </span> ${text}`,
      markup: "pango",
      separator: false,
      separator_block_width: 6
    }
  }

  f.id = uuid()
  return f
}

exports.calendar = block(
  {
    interval: 1000,
    icon: "DATE"
  },
  () => moment().format("dddd, MMMM Do")
)

exports.clock = block(
  {
    interval: 1000,
    icon: "TIME"
  },
  () => moment().format("hh:mm:ss A")
)

exports.memory = block(
  {
    interval: 500,
    icon: "MEMORY"
  },
  () => ~~(os.freemem() / os.totalmem() * 1000) / 10 + "%"
)

exports.dolartoday = block(
  {
    interval: 60000,
    icon: "BSF"
  },
  () => {
    const res = await fetch('https://s3.amazonaws.com/dolartoday/data.json')
    const { USD, EUR }  = await res.json()

    return `${USD.dolartoday}$/${EUR.dolartoday}€`
  }
)

exports.cpu = block(
  {
    interval: 500,
    icon: "CPU"
  },
  () => {
    const cpus = os.cpus()
    let idle = 0
    let total = 0

    for (let cpu of cpus) {
      idle += cpu.times.idle

      for (type in cpu.times) {
        total += cpu.times[type]
      }
    }

    // idle /= cpus.length
    // total /= cpus.length

    return 1 - idle / total + "%"
  }
)
