import React from 'react'
import Line from "./line"

// TODO: interpret `literals` as commands to parse
export const Echo = async (input) => (await <div>{input.join(" ")}</div>)

export const Help = async (input) => (await <div>
  ARL Visualizer pseudo-CLI: version 0.0.1 <br></br><br></br>
  This is the help message, sorry it's so unhelpful. Here are the currently supported commands: <br></br>
  help -- display this help message <br></br>
  echo -- display a line of text <br></br>
  clear -- clears the terminal <br></br>
  pwd -- display current location of server
  </div>)

export const Clear = async (input) => (
  await function () { this.props.clearLines() }
)

export const Pwd = async (input) => (await <div>{window.origin}</div>)