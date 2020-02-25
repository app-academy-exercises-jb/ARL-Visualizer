import React from 'react'
import styled from 'styled-components'

const JLine = styled.div`
  display: flex;
`;

const Property = styled.div`
  color: purple;
`;

const Separator = styled.div`
  color: grey;
`;

const Value = styled.div`
  whitespace: none;
  color: ${({type}) => (type === "int" ? "cyan" : 
    type === "date" ? "lightgreen" : 
    type === "bool" ? "lightpink" : 
    type === "str" ? "red" : "grey")};
`;

class PrettyObject extends React.Component {
  constructor (props) {
    super(props)

    const { newObj, types } = this.parseInput(props.obj);
    
    this.state = {
      obj: newObj,
      types,
      last: props.last === undefined ? true : props.last,
      hidden: props.hidden || false
    };

    this.expandable = this.expandable.bind(this);
    this.parseInput = this.parseInput.bind(this);
  }

  parseInput(input) {
    const obj = input,
      newObj = {},
      types = {};

    for (let k in obj) {
      if (!isNaN(parseInt(obj[k], 10)) && !(/-/.test(obj[k]))) {
        newObj[k] = parseInt(obj[k], 10);
        types[k] = "int";
      } else if (!isNaN(Date.parse(obj[k]))) {
        newObj[k] = new Date(Date.parse(obj[k])).toLocaleString();
        types[k] = "date";
      } else if (["true", "false"].includes(obj[k])) {
        newObj[k] = /true/.test(obj[k]);
        types[k] = "bool";
      } else {
        newObj[k] = obj[k];
        types[k] = "str";
      }
    }
    
    return {newObj, types};
  }

  expandable(e) {
    this.setState({
      hidden: !this.state.hidden
    });
  }

  render () {
    const obj = this.state.obj,
      types = this.state.types;

    if (this.state.hidden) {
      return <div onClick={this.expandable} style={{color:"green"}}>
        {"{"} {this.props.type} {"}"}
        {this.state.last ? "" : ","}
      </div>
    } else {
      return <div onClick={this.expandable} style={{color:"green"}}>
        {'{'}
        {Object.keys(obj).map((k,i) => {
          return <JLine key={i}>
              <Property>{k}</Property>
              <Separator>: </Separator> 
              <Value type={types[k]}>
                { Array.isArray(obj[k]) ? obj[k].join(", ") : obj[k] }
              </Value>
            </JLine>
        })}
      {'}'}{this.state.last ? "" : ","}</div>
    }
  }
}

function PrettySast(props) {

}

export default function PrettyParser({ res }) {
  if (res.val && Array.isArray(res.val)) {
    return res.val.map((r,i) => {
      return <PrettyObject key={i} type={res.type} obj={r} last={!(i < res.val.length - 1)}/>
    });
  } else if (typeof res === 'object') {
    if (res.type !== "sast") {
      return <PrettyObject type={res.type} obj={res.val} />
    } else {
      return JSON.stringify(res, null, 2)
      return <PrettySast type={res.val.type} obj={res.val.query} />
    }
  }
  return JSON.stringify(res, null, 2)
}