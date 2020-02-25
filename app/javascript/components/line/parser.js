function checkCommands(input) {
  const commands = ["echo","help","clear","pwd","classes"],
    match = commands.filter(c => (c === input.split(" ")[0]));

  if (match.length === 1) {
    return {
      type: "command",
      command: match[0][0].toUpperCase() + match[0].slice(1),
      input: input.split(" ").slice(1)
    }
  } else {
    return input
  }
}

function Parser(input) {
  return checkCommands(input);
}

export default Parser;