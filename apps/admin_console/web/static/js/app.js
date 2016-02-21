import "phoenix_html"
import socket from "./socket"

socket.connect()

let channel = socket.channel("events:all", {})

channel.on("new_event", payload => {
  payload = payload.message
  console.log(`Event: type - ${payload.type} message - ${payload.message}`)
})

channel.join()
  .receive("ok", () => {
    channel.push("block", {url: "todo.cbrenn.xyz"})
  })
