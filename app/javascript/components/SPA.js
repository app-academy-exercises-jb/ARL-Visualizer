import React from "react"
import styled, { ThemeProvider } from 'styled-components'
import Line from "./Line"

const Body = styled.div`
  margin: 0px;
  height: 100%;
  width: 100%;
  min-height: 100vh;
  max-height: auto;
  text-align: initial;
  background-color: #2c2c2c;
  color: #c8c8c8;
`;

class Terminal extends React.Component {
  constructor(props) {
    super(props);

    this.inputRef = React.createRef();
    this.handleClick = this.handleClick.bind(this);
    this.getLines = this.getLines.bind(this);
    this.switchLine = this.switchLine.bind(this);
    this.newLine = this.newLine.bind(this);
    this.history = this.history.bind(this);

    const line = this.newLine();
    this.state = {
      lines: [line],
      currentLine: line,
      history: [],
      historyIdx: -1,
      currentInput: ""
    };
  }

  newLine() {
    return (<Line 
      ref={(ch) => this.prompt = ch}
      current={true} 
      switchLine={this.switchLine}
      history={this.history}
      />)
  }

  history(dir, value) {
    let newIdx = this.state.historyIdx + dir,
      length = this.state.history.length;

    //maintain newIdx within the bounds of the history array
    if (newIdx < -1) {
      newIdx = -1;
    } else {
      newIdx = length === 0 ? 
        -1 : 
        (newIdx > length - 1 ? 
          length - 1 : 
          newIdx);
    }

    this.setState({historyIdx: newIdx});
    if (this.state.historyIdx < newIdx && newIdx === 0) {
      this.setState({currentInput: value});
    }

    if (newIdx === -1) {
      return this.state.currentInput
    } else {
      return this.state.history[newIdx]
    }
  }

  switchLine(input) {
    let newLines = [...this.state.lines, this.newLine()],
      newHistory = input === this.state.history[0] ? 
        this.state.history :
        [input, ...this.state.history];
  
    
    this.setState({
      lines: newLines,
      currentLine: newLines[newLines.length - 1],
      history: newHistory,
      historyIdx: -1
    });
  }

  componentDidMount() {
    this.prompt.inputRef.focus();
  }

  componentDidUpdate() {
    this.prompt.inputRef.focus();
  }

  handleClick() {
    this.prompt.inputRef.focus();
  }

  getLines() {
    return (
      <div>
        {this.state.lines.map((l,i) => { return (
          <div key={i}>
            <br></br>
            <div>{l}</div>
            <br></br>
          </div>
        ) })}
      </div>
    );
  }

  render () {
    return (
      <Body onClick={this.handleClick}>
        {this.getLines()}
      </Body>
    );
  }
}

export default Terminal
