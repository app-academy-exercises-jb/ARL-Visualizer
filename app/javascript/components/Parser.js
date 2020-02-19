function Lexer(input) {
  const commands = ["help","clear","pwd","man","grep"],
    queries=["select"]

  const currentToken = "",
    tokens = [];

  for (let c in input) {
    const chr = input[c];
    
    console.log(chr)
    if (/\s/.test(chr)) {
      console.log("space")
    } else if (/\d/.test(chr)) {
      console.log("number")
    } else if (/\w/.test(chr)) {
      console.log("mid-word")
    }

  }
}

function Parser(input) {
  const tokens = Lexer(input)
  return {input: input}
}

export default Parser;