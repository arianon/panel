const os = require("os")
const si = require("systeminformation")
const uuid = require("uuid")
const moment = require("moment")
const fetch = require("node-fetch")

const block = ({ interval, icon }, callback) => {
  async function f() {
    const ret = await callback()

    if (ret == null) {
      return null
    }

    let color = "white"
    let text = ""
    if (typeof ret === "object" && ret.text) {
      text = ret.text
      color = ret.color || color
    } else {
      text = ret
    }

    return {
      full_text: `<span background='${color}' foreground='black'> ${icon.trim()} </span> ${text}`,
      markup: "pango",
      separator: false,
      separator_block_width: 6
    }
  }

  f.id = uuid()
  f.interval = interval
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
    interval: 1000,
    icon: "MEMORY"
  },
  async () => {
    const { active, total } = await si.mem()
    const perc = active / total * 100

    let color
    if (perc >= 90) {
      color = "red"
    } else if (perc >= 75) {
      color = "yellow"
    } else {
      color = "white"
    }

    return {
      text: perc.toFixed(1) + "%",
      color: color
    }
  }
)

exports.dolartoday = block(
  {
    interval: 60000,
    icon: "EXG"
  },
  async () => {
    try {
      const res = await fetch("https://s3.amazonaws.com/dolartoday/data.json")

      if (!res.ok) {
        throw res.statusText
      }

      const { USD } = await res.json()

      return `${~~USD.dolartoday}/COP - ${~~USD.bitcoin_ref}/BTC`
    } catch (_e) {
      return null
    }
  }
)

exports.cpu = block(
  {
    interval: 1000,
    icon: "CPU"
  },
  async () => {
    const { currentload } = await si.currentLoad()

    let color
    if (currentload >= 90) {
      color = "red"
    } else if (currentload >= 75) {
      color = "yellow"
    } else {
      color = "white"
    }

    return { text: currentload.toFixed(1) + "%", color: color }
  }
)
