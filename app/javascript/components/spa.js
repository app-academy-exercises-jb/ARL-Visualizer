import React from "react"
import styled, { ThemeProvider } from 'styled-components'
import Line from "./line/line"

const Body = styled.div`
  z-index: 0;
  position: absolute;
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
    this.clearLines = this.clearLines.bind(this);
    this.newLine = this.newLine.bind(this);
    this.history = this.history.bind(this);
    this.newHistory = this.newHistory.bind(this);

    const line = this.newLine(0);
    this.state = {
      lines: [line],
      currentLine: line,
      lineIdx: 0,
      history: [],
      historyIdx: -1,
      currentInput: ""
    };
  }

  newLine(key) {
    return (<Line 
      ref={(ch) => this.prompt = ch}
      current={true} 
      switchLine={this.switchLine}
      clearLines={this.clearLines}
      history={this.history}
      key={key}
      ip={this.props.ip}
      classes={this.props.classes}
    />)
  }

  componentDidMount() {
    //simulate "help"
    this.prompt.keyDownHandler({keyCode: 13, target: {value: "help"}})
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

    //only reset currentInput coming out of the current input
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

  newHistory(input) {
    return input === this.state.history[0]
      ? this.state.history
      : [input, ...this.state.history];
  }

  switchLine(input) {
    const history = this.newHistory(input),
      lineIdx = this.state.lineIdx + 1,
      lines = [...this.state.lines, this.newLine(lineIdx)];
  
    this.setState({
      lines,
      currentLine: lines[lines.length - 1],
      history,
      historyIdx: -1,
      lineIdx
    });
  }

  clearLines() {
    const lineIdx = this.state.lineIdx + 1,
      line = this.newLine(lineIdx),
      lines = [line];
    
    this.setState({
      lines,
      currentLine: line,
      historyIdx: -1,
      lineIdx
    });
  }

  handleClick() {
    this.prompt.inputRef.focus();
  }

  getLines() {
    // debugger
    return (
      <div>
        {this.state.lines.map((l) => { return (
          <div key={l.key}>
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
