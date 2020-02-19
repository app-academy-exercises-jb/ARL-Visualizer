import React from "react"
import styled, { ThemeProvider } from 'styled-components'
import Parser from './Parser'


const Prompt = styled.input`
  font: inherit;
  font-size: 1em;
  &, &:focus {
    width: 90%;
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
    async function getData(url='',data={}) {
      const response = await fetch(url, {
        method: 'POST',
        mode: "cors",
        cache: "no-cache",
        headers: { "Content-Type": "application/json" },
        redirect: "manual",
        body: JSON.stringify(data)
      });
      return await response.json();
    }

    const req = this.parse()

    getData(location.origin + "/api/v1/command", req)
      .then(res => {
        this.setState({ response: JSON.stringify(res) })
      }).catch(err => {
        this.setState({ response: JSON.stringify(err.toString()) })
      });
  }

  getIO() {
    if (this.state.response === null) this.getOutput(this.input);

    return (
      <div>
        {this.input}
        <br></br>
        {this.state.response}
      </div>
    )
  }

  showPrompt() {
    return (<div>
      $<Prompt 
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