import React from "react"
import styled, { ThemeProvider } from 'styled-components'
import Parser from './parser'
import * as Commands from "./commands"
import { getData } from "../../utils/utils"


const Resp = styled.div`
  white-space: pre;
`;

const Prompt = styled.input`
  font: inherit;
  font-size: 1em;
  &, &:focus {
    width: fit-content;
    border: none;
    padding: 0;
    outline: none;
    margin: none;
    background: #2c2c2c;
    color: #c8c8c8;
  }
`;

class Line extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      current: props.current,
      response: null
    };
    this.inputRef = React.createRef();
    this.showPrompt = this.showPrompt.bind(this);
    this.keyDownHandler = this.keyDownHandler.bind(this);
    this.getIO = this.getIO.bind(this);
  }

  componentDidMount() {
    this.inputRef.focus();
  }

  keyDownHandler(event) {
    if (event.key === "ArrowUp") {
      event.preventDefault();
      event.target.value = this.props.history(1, event.target.value)
    } else if (event.key === "ArrowDown") {
      event.preventDefault();
      event.target.value = this.props.history(-1, event.target.value)
    } else if (event.keyCode === 13) {
      this.input = event.target.value;
      this.setState({current: false});
      this.inputRef = null;
      this.props.switchLine(this.input);
    }
  }

  parse() {
    return Parser(this.input);
  }

  getOutput() {
    const req = this.parse()

    if (typeof req === "object") {
      Commands[req.command](req.input)
        .then(response => {
          if (typeof response === "function") {
            response.apply(this);
          } else if (typeof response === "object") {
            this.setState({ response })
          }
        }).catch(err => {
          this.setState({ response: JSON.stringify(err.toString()) })
        })
    } else if (typeof req === "string") {
      Commands["Query"]().then(response => response.apply(this, [req]))
    }
  }

  getIO() {
    if (this.state.response === null) this.getOutput(this.input);

    return (
      <div>
        [{this.props.ip}]$ {this.input}
        <br></br>
        <Resp>
          {this.state.response}
        </Resp>
      </div>
    )
  }

  showPrompt() {
    return (<div>
      [{this.props.ip}]$ <Prompt 
        ref={(ip) => this.inputRef = ip}
        onKeyDown={this.keyDownHandler}
      >
      </Prompt>
    </div>)
  }

  render() {
    return (
      this.state.current ? this.showPrompt() : this.getIO()
    )
  }
}

export default Line