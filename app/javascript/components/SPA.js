import React from "react"
import PropTypes from "prop-types"
import Terminal from 'terminal-in-react';

class SPA extends React.Component {
  render () {
    async function getData(url='',data={}) {
      const response = await fetch(url);
      return await response.json();
    }

    const commands = {
      "teset": (args, print, runCommand) => {
        //runCommand(details, options)...utils.js
        let response = getData(location.origin + "/api/v1/test");
        debugger
        return response
      }
    }, descriptions = {
    }, message = 'This is bungalo johnson on rails!!!!';

    return (
      <div
      style={{
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        height: "100vh"
      }}>
      <Terminal
        hideTopBar='true'
        startState="maximised"
        allowTabs="false"
        color='#b8b8b8'
        backgroundColor='#2c2c2c'
        barColor='black'
        style={{ fontWeight: "bold", fontSize: "1em" }}
        commands={commands}
        descriptions={descriptions}
        msg={message}
      />
    </div>
    );
  }
}

export default SPA
