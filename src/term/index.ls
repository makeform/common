module.exports =
  pkg:
    dependencies: [
    * name: \ldview
    * name: \@plotdb/form
    * name: \ldcover
    * name: \ldcover, type: \css, global: true
    ]
  interface: -> @mod.ldcv
  init: ({root, ctx}) ->
    {ldcover,form} = ctx
    mod = @{}mod
    mod.ldcv = new ldcover root: root
    mod.ldcv.on \data, (p) ->
      mod.terms = if Array.isArray(p) => JSON.parse(JSON.stringify(p)) else []
      mod.view.render!
    mod.view = new ldview do
      root: root
      action: click:
        add: ({views}) ->
          mod[]terms.push {id: Math.random!toString(36)substring(2)}; views.0.render!
        close: ->
          console.log mod.terms
          mod.ldcv.set term: (mod.terms or [])
      handler:
        term:
          list: -> mod[]terms
          key: -> it.id
          view:
            action:
              click:
                enabled: ({ctx, views}) -> ctx.enabled = !ctx.enabled; views.0.render!
                delete: ({ctx, views, ctxs}) -> ctxs.0.splice(ctxs.0.indexOf(ctx), 1); views.1.render!
              change:
                opset: ({node, ctx, views}) ->
                  ctx.opset = node.value
                  views.0.render!
                op: ({node, ctx, views}) ->
                  ctx.op = node.value
                  views.0.render!
            handler:
              enabled: ({node, ctx}) -> node.classList.toggle \on, !!ctx.enabled
              "opset-option":
                list: -> form.opset.list!
                key: -> it.id or it.name
                view:
                  handler: "@": ({node, ctx}) ->
                    node.value = ctx.id or ctx.name
                    node.textContent = ctx.name or ctx.id
              "op-option":
                list: ({ctx}) ->
                  opset = form.opset.get(ctx.opset)
                  [{k, v} for k, v of (opset?ops or {})]
                key: -> it.k
                view:
                  handler: "@": ({node, ctx}) ->
                    node.value = ctx.v.id or ctx.v.name or ctx.k
                    node.textContent = ctx.v.name or ctx.v.id or ctx.k
              "op-cfg":
                list: ({ctx}) ->
                  if !(opset = form.opset.get(ctx.opset)) => return []
                  if !(op = opset.get-op(ctx.op)) => return []
                  [{k,v} for k,v of (op?config or {})]
                key: -> it.k
                view:
                  action:
                    change:
                      value: ({node, ctx, ctxs}) -> ctxs.0{}config[ctx.k] = node.value
                      msg: ({node, ctx, ctxs}) -> ctxs.0{}msg = node.value
                    input:
                      value: ({node, ctx, ctxs}) -> ctxs.0{}config[ctx.k] = node.value
                      msg: ({node, ctx, ctxs}) -> ctxs.0{}msg = node.value
                  handler:
                    value: ({node, ctx, ctxs}) -> node.value = ctxs.0?config?[ctx.k] or ''
                    msg: ({node, ctx, ctxs}) -> node.value = ctxs.0?msg or ''
                    name: ({node, ctx}) -> node.textContent = ctx?v?name or ctx?k

