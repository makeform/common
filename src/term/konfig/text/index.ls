module.exports =
  pkg: extend: name: '@plotdb/konfig', version: 'main', path: 'text', dom: \overwrite
  init: ({root, data, pubsub, parent}) ->
    view = new ldview do
      root: root
      init: dropdown: ({node}) -> new BSN.Dropdown node
      handler:
        menu: ({node, local}) ->
          if !local.parent => local.parent = node.parentNode
          show = !!(parent._values and parent._values.length)
          if show and !node.parentNode => node.parentNode.appendChild node
          else if !show and node.parentNode => node.parentNode.removeChild node
    pubsub.on \render, -> view.render!
